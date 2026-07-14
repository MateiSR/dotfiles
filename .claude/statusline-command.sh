#!/usr/bin/env bash

input=$(cat)
mapfile -t values < <(jq -r '
  [
    (.context_window.used_percentage // ""),
    (.rate_limits.five_hour.used_percentage // ""),
    (.rate_limits.seven_day.used_percentage // ""),
    ((.rate_limits.five_hour.resets_at // null) | if . == null then "" else floor end),
    ((.rate_limits.seven_day.resets_at // null) | if . == null then "" else floor end),
    (.model.display_name // ""),
    (.cwd // .workspace.current_dir // ""),
    (.cost.total_cost_usd // "")
  ] | .[]
' <<< "$input")

used_pct=${values[0]:-}
five_pct=${values[1]:-}
seven_pct=${values[2]:-}
five_reset=${values[3]:-}
seven_reset=${values[4]:-}
model=${values[5]:-}
cwd=${values[6]:-$PWD}
cost=${values[7]:-}

reset="\033[0m"
bold="\033[1m"
dim="\033[2m"
gray="\033[38;5;245m"
warm="\033[38;5;216m"
orange="\033[38;5;209m"
terra="\033[38;5;173m"
green="\033[38;5;108m"
yellow="\033[38;5;179m"
red="\033[38;5;167m"
now_ts=$(date +%s)
parts=()

fmt_countdown() {
	local secs=${1:-0}
	((secs > 0)) || { printf 'now'; return; }
	local days=$((secs / 86400))
	local hours=$(((secs % 86400) / 3600))
	local mins=$(((secs % 3600) / 60))
	if ((days)); then
		printf '%dd%dh' "$days" "$hours"
	elif ((hours)); then
		printf '%dh%dm' "$hours" "$mins"
	else
		printf '%dm' "$mins"
	fi
}

make_bar() {
	local pct=${1:-0} filled color
	filled=$(((pct * 8 + 50) / 100))
	((filled > 8)) && filled=8
	if ((pct < 60)); then
		color=$orange
	elif ((pct < 85)); then
		color=$terra
	else
		color=$red
	fi
	local blocks=████████ empties=░░░░░░░░
	printf '%b%s%b%s%b' "$color" "${blocks:0:filled}" "$gray" "${empties:0:8-filled}" "$reset"
}

add_limit() {
	local label=$1 pct=$2 reset_at=$3
	[[ -n $pct ]] || return
	local int bar suffix="" remaining countdown clock
	int=$(printf '%.0f' "$pct")
	bar=$(make_bar "$int")
	if [[ -n $reset_at ]]; then
		remaining=$((reset_at - now_ts))
		countdown=$(fmt_countdown "$remaining")
		if ((remaining > 0 && remaining < 86400)); then
			clock=$(date -d "@$reset_at" +%H:%M 2>/dev/null || true)
		fi
		if [[ -n ${clock:-} ]]; then
			suffix=" ${dim}${countdown}→${clock}${reset}"
		else
			suffix=" ${dim}${countdown}${reset}"
		fi
	fi
	parts+=("$(printf '%b' "${gray}${label} ${reset}${bar} ${warm}${int}%${reset}${suffix}")")
}

if [[ -n $used_pct ]]; then
	used_int=$(printf '%.0f' "$used_pct")
	if ((used_int < 50)); then
		ctx_color=$green
	elif ((used_int < 80)); then
		ctx_color=$yellow
	else
		ctx_color=$red
	fi
	parts+=("$(printf '%b' "${gray}ctx ${reset}${ctx_color}${bold}${used_int}%${reset}")")
fi

add_limit 5h "$five_pct" "$five_reset"
add_limit 7d "$seven_pct" "$seven_reset"
[[ -z $model ]] || parts+=("$(printf '%b' "${orange}${model}${reset}")")
[[ -z $cost ]] || parts+=("$(printf '%b' "${terra}$(printf '$%.2f' "$cost")${reset}")")

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
[[ -z $git_branch ]] || parts+=("$(printf '%b' "${warm}${git_branch}${gray}${git_dirty}${reset}")")

sep="${gray}│${reset}"
out=""
for i in "${!parts[@]}"; do
	((i == 0)) || out+=" $(printf '%b' "$sep") "
	out+="${parts[$i]}"
done
[[ -z $out ]] || printf '%b\n' "$out"
