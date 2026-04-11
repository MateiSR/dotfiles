#!/usr/bin/env bash
# Claude Code status line - plain, minimal, standard ANSI only

input=$(cat)

# ANSI colors — Claude Code palette (warm oranges, reds, grays)
reset="\033[0m"
bold="\033[1m"
dim="\033[2m"
gray="\033[38;5;245m"         # labels, separators
warm="\033[38;5;216m"         # warm peach — accent text
orange="\033[38;5;209m"       # salmon orange — primary accent
terra="\033[38;5;173m"        # terra cotta — secondary accent
green="\033[38;5;108m"        # muted sage green
yellow="\033[38;5;179m"       # muted gold
red="\033[38;5;167m"          # muted warm red

# Format a countdown given seconds remaining.
# - <= 0     : "now"
# - < 1h     : "Xm"
# - < 24h    : "XhYm"
# - >= 24h   : "XdYh"
fmt_countdown() {
    local secs="${1:-0}"
    if [ "$secs" -le 0 ]; then printf "now"; return; fi
    local days=$(( secs / 86400 ))
    local hours=$(( (secs % 86400) / 3600 ))
    local mins=$(( (secs % 3600) / 60 ))
    if   [ "$days"  -gt 0 ]; then printf "%dd%dh" "$days" "$hours"
    elif [ "$hours" -gt 0 ]; then printf "%dh%dm" "$hours" "$mins"
    else                          printf "%dm" "$mins"
    fi
}

# Build a small inline bar: [████░░░░] with colored fill
# Bar width: 8 filled+empty chars
make_bar() {
    local pct="${1:-0}"
    local width=8
    local filled=$(( (pct * width + 50) / 100 ))
    [ "$filled" -gt "$width" ] && filled=$width
    local empty=$(( width - filled ))
    # Color the fill: orange < 60%, warm red 60-85%, red > 85%
    local fill_color
    if   [ "$pct" -lt 60 ]; then fill_color="$orange"
    elif [ "$pct" -lt 85 ]; then fill_color="$terra"
    else                          fill_color="$red"
    fi
    local bar=""
    bar+=$(printf "%b" "$fill_color")
    local i
    for (( i=0; i<filled; i++ )); do bar+="█"; done
    bar+=$(printf "%b" "$gray")
    for (( i=0; i<empty;  i++ )); do bar+="░"; done
    bar+=$(printf "%b" "$reset")
    printf "%s" "$bar"
}

# Context window usage
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Rate limits
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '(.rate_limits.five_hour.resets_at // empty) | floor')
seven_reset=$(echo "$input" | jq -r '(.rate_limits.seven_day.resets_at // empty) | floor')
now_ts=$(date +%s)

# Model display name
model=$(echo "$input" | jq -r '.model.display_name // empty')

# Git branch (no optional locks to avoid interfering with Claude)
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
[ -z "$cwd" ] && cwd="$(pwd)"

git_branch=""
git_dirty=""
if git -C "$cwd" --no-optional-locks rev-parse --git-dir >/dev/null 2>&1; then
    git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
                 || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    if ! git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null \
       || ! git -C "$cwd" --no-optional-locks diff --cached --quiet 2>/dev/null; then
        git_dirty="*"
    fi
fi

sep="${gray}│${reset}"
parts=()

# Context usage with color coding
if [ -n "$used_pct" ]; then
    used_int=$(printf '%.0f' "$used_pct")
    if   [ "$used_int" -lt 50 ]; then ctx_color="$green"
    elif [ "$used_int" -lt 80 ]; then ctx_color="$yellow"
    else                               ctx_color="$red"
    fi
    parts+=("$(printf "%b" "${gray}ctx ${reset}${ctx_color}${bold}${used_int}%${reset}")")
fi

# 5-hour rate limit bar with percentage + reset countdown & wall-clock
if [ -n "$five_pct" ]; then
    five_int=$(printf '%.0f' "$five_pct")
    bar=$(make_bar "$five_int")
    five_reset_txt=""
    if [ -n "$five_reset" ]; then
        cdown=$(fmt_countdown $(( five_reset - now_ts )))
        clock=$(date -d "@$five_reset" +%H:%M 2>/dev/null)
        if [ -n "$clock" ]; then
            five_reset_txt=" ${dim}${cdown}→${clock}${reset}"
        else
            five_reset_txt=" ${dim}${cdown}${reset}"
        fi
    fi
    parts+=("$(printf "%b" "${gray}5h ${reset}${bar} ${warm}${five_int}%${reset}${five_reset_txt}")")
fi

# 7-day rate limit bar with percentage + reset countdown
if [ -n "$seven_pct" ]; then
    seven_int=$(printf '%.0f' "$seven_pct")
    bar=$(make_bar "$seven_int")
    seven_reset_txt=""
    if [ -n "$seven_reset" ]; then
        remaining=$(( seven_reset - now_ts ))
        cdown=$(fmt_countdown "$remaining")
        # If the 7d window resets within a day, wall-clock is meaningful too
        if [ "$remaining" -gt 0 ] && [ "$remaining" -lt 86400 ]; then
            clock=$(date -d "@$seven_reset" +%H:%M 2>/dev/null)
            if [ -n "$clock" ]; then
                seven_reset_txt=" ${dim}${cdown}→${clock}${reset}"
            else
                seven_reset_txt=" ${dim}${cdown}${reset}"
            fi
        else
            seven_reset_txt=" ${dim}${cdown}${reset}"
        fi
    fi
    parts+=("$(printf "%b" "${gray}7d ${reset}${bar} ${warm}${seven_int}%${reset}${seven_reset_txt}")")
fi

# Model name
if [ -n "$model" ]; then
    parts+=("$(printf "%b" "${orange}${model}${reset}")")
fi

# Session cost
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$cost" ]; then
    cost_fmt=$(printf '$%.2f' "$cost")
    parts+=("$(printf "%b" "${terra}${cost_fmt}${reset}")")
fi

# Git branch
if [ -n "$git_branch" ]; then
    parts+=("$(printf "%b" "${warm}${git_branch}${gray}${git_dirty}${reset}")")
fi

# Join parts with separator
out=""
for i in "${!parts[@]}"; do
    [ "$i" -gt 0 ] && out+=" $(printf "%b" "$sep") "
    out+="${parts[$i]}"
done

[ -n "$out" ] && printf "%b\n" "$out"
