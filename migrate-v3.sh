#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
STATE_ROOT=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-migration
ASSUME_YES=false
DRY_RUN=false
CUTOVER_STARTED=false
CURRENT_POINT=""

USER_PATHS=(
	.config/btop
	.config/dotfiles
	.config/fish
	.config/gtk-3.0
	.config/gtk-4.0
	.config/hypr
	.config/ironbar
	.config/kitty
	.config/matugen
	.config/nvim
	.config/opencode
	.config/qt5ct
	.config/qt6ct
	.config/rofi
	.config/swaync
	.config/swayosd
	.config/starship.toml
	.config/vicinae
	.config/waybar
	.config/waypaper
	.config/wlogout
	.config/wob
	.config/yazi
	.config/zed
	.config/zathura
	.config/zellij
	.gitconfig
	.tmux.conf
)

LOCAL_PATHS=(
	.config/dotfiles/machine.lua
	.config/dotfiles/git.conf
	.config/dotfiles/scripts/gs_zipline_conf.sh
	.config/fish/conf.d/local.fish
	.config/waypaper/config.ini
)

usage() {
	cat <<'EOF'
Usage:
  ./migrate-v3.sh check
  ./migrate-v3.sh migrate [--dry-run] [--yes]
  ./migrate-v3.sh list
  ./migrate-v3.sh restore [RESTORE_POINT|latest] [--dry-run] [--yes]

Commands:
  check     Validate the repository and report current Stow collisions.
  migrate   Archive the live config, install prerequisites, and apply v3.
  list      List complete restore points.
  restore   Restore user config, SDDM state, and the legacy HyprPM plugin.

Restore points live under:
  ~/.local/state/dotfiles-migration/
EOF
}

step() {
	printf '\n==> %s\n' "$*"
}

warn() {
	printf 'warning: %s\n' "$*" >&2
}

die() {
	printf 'error: %s\n' "$*" >&2
	return 1
}

run() {
	printf '  '
	printf '%q ' "$@"
	printf '\n'
	$DRY_RUN || "$@"
}

confirm() {
	local answer
	$ASSUME_YES && return
	read -r -p "$1 [y/N] " answer
	[[ $answer == [yY] || $answer == [yY][eE][sS] ]] || die "cancelled"
}

require_command() {
	command -v "$1" >/dev/null || die "missing command: $1"
}

managed_path() {
	case $1 in
	.config/*|.gitconfig|.tmux.conf) return 0 ;;
	*) return 1 ;;
	esac
}

target_is_source_link() {
	local source=$1 target=$2 source_real target_real
	[[ -L $target ]] || return 1
	source_real=$(readlink -f -- "$source")
	target_real=$(readlink -f -- "$target" 2>/dev/null || true)
	[[ -n $target_real && $target_real == "$source_real" ]]
}

audit_targets() {
	local path source target total=0 linked=0 missing=0 conflicts=0
	while IFS= read -r -d '' path; do
		managed_path "$path" || continue
		((total += 1))
		source=$ROOT/$path
		target=$HOME/$path
		if target_is_source_link "$source" "$target"; then
			((linked += 1))
		elif [[ -e $target || -L $target ]]; then
			((conflicts += 1))
		else
			((missing += 1))
		fi
	done < <(git -C "$ROOT" ls-files -z)
	printf '%d %d %d %d\n' "$total" "$linked" "$missing" "$conflicts"
}

legacy_plugin_enabled() {
	local output
	command -v hyprpm >/dev/null || return 1
	output=$(hyprpm list 2>/dev/null | sed -E $'s/\x1B\[[0-9;]*[[:alpha:]]//g')
	awk '
		/Repository split-monitor-workspaces/ { in_repo = 1; next }
		in_repo && /Repository / { exit }
		in_repo && /enabled: true/ { found = 1; exit }
		END { exit !found }
	' <<< "$output"
}

preflight() {
	local branch total linked missing conflicts
	((EUID != 0)) || die "run this as your user, not root"
	for command in git tar sha256sum pacman sudo; do
		require_command "$command"
	done
	[[ ! -d /usr/share/sddm/themes/sddm-astronaut-theme || -x /usr/share/sddm/themes/sddm-astronaut-theme ]] \
		|| die "SDDM theme is not traversable; restore a clean point before migrating"

	branch=$(git -C "$ROOT" branch --show-current)
	[[ $branch == v3 ]] || die "expected branch v3, found ${branch:-detached HEAD}"
	git -C "$ROOT" diff --check
	bash -n "$ROOT/bootstrap.sh" "$ROOT/install.sh" "$ROOT/migrate-v3.sh"
	if [[ -n $(git -C "$ROOT" status --porcelain) ]]; then
		warn "repository has local changes; they will be the stowed version"
	fi

	if command -v Hyprland >/dev/null; then
		DOTFILES_VERIFY_CONFIG=1 Hyprland --verify-config -c "$ROOT/.config/hypr/hyprland.lua" >/dev/null
	fi
	"$ROOT/install.sh" --dry-run >/dev/null

	read -r total linked missing conflicts < <(audit_targets)
	printf 'branch: v3\nmanaged files: %d\nalready linked: %d\nmissing targets: %d\nconflicting targets: %d\n' \
		"$total" "$linked" "$missing" "$conflicts"
	command -v stow >/dev/null || warn "GNU Stow is not installed yet; migrate installs it first"
	printf 'preflight: ok\n'
}

record_state() {
	local point=$1
	{
		printf 'created=%s\n' "$(date --iso-8601=seconds)"
		printf 'host=%s\n' "$(hostname)"
		printf 'repository=%s\n' "$ROOT"
		printf 'branch=%s\n' "$(git -C "$ROOT" branch --show-current)"
		printf 'commit=%s\n' "$(git -C "$ROOT" rev-parse HEAD)"
	} > "$point/metadata"
	git -C "$ROOT" status --short --branch > "$point/git-status"
	pacman -Q > "$point/packages" 2>/dev/null || true
	hyprctl monitors all > "$point/hypr-monitors" 2>&1 || true
	hyprctl plugin list > "$point/hypr-plugins" 2>&1 || true
	hyprpm list > "$point/hyprpm" 2>&1 || true
	legacy_plugin_enabled && : > "$point/legacy-plugin-enabled"
}

archive_user_config() {
	local point=$1 path
	local archive=$point/user-home.tar.gz
	local -a present=()
	for path in "${USER_PATHS[@]}"; do
		[[ -e $HOME/$path || -L $HOME/$path ]] && present+=("$path")
	done
	((${#present[@]})) || die "none of the expected user config paths exist"

	step "Archive live user configuration"
	tar --acls --xattrs -C "$HOME" -czpf "$archive.tmp" "${present[@]}"
	mv -- "$archive.tmp" "$archive"
	tar -tzf "$archive" >/dev/null
}

archive_system_config() {
	local point=$1 path
	local archive=$point/system-sddm.tar.gz
	local -a present=()
	for path in etc/sddm.conf.d usr/share/sddm/themes/sddm-astronaut-theme var/lib/matugen-sddm; do
		if [[ -e /$path || -L /$path ]]; then
			present+=("$path")
		fi
	done
	((${#present[@]})) || return

	step "Archive SDDM configuration"
	sudo tar --acls --xattrs -C / -czpf "$archive.tmp" "${present[@]}"
	sudo chown "$(id -u):$(id -g)" "$archive.tmp"
	mv -- "$archive.tmp" "$archive"
	tar -tzf "$archive" >/dev/null
}

create_restore_point() {
	local timestamp point
	timestamp=$(date +%Y%m%d-%H%M%S)
	point=$STATE_ROOT/$timestamp
	install -d -m 0700 "$STATE_ROOT" "$point"
	record_state "$point"
	archive_user_config "$point"
	archive_system_config "$point"
	(
		cd "$point"
		sha256sum user-home.tar.gz system-sddm.tar.gz 2>/dev/null > SHA256SUMS || sha256sum user-home.tar.gz > SHA256SUMS
	)
	: > "$point/COMPLETE"
	ln -sfn -- "$point" "$STATE_ROOT/latest"
	CURRENT_POINT=$point
}

record_created() {
	printf '%s\n' "$1" >> "$CURRENT_POINT/created-user-paths"
}

prepare_local_overrides() {
	local machine=$HOME/.config/dotfiles/machine.lua
	local git_config=$HOME/.config/dotfiles/git.conf
	local zipline=$HOME/.config/dotfiles/scripts/gs_zipline_conf.sh
	local fish_config=$HOME/.config/fish/config.fish
	local local_fish=$HOME/.config/fish/conf.d/local.fish
	local wine_line

	step "Prepare machine-local configuration"
	install -d "$HOME/.config/dotfiles" "$HOME/.config/fish/conf.d"
	if [[ ! -e $machine ]]; then
		record_created .config/dotfiles/machine.lua
		install -m 0600 "$ROOT/.config/dotfiles/machine.lua.example" "$machine"
	fi

	if [[ ! -e $git_config ]]; then
		record_created .config/dotfiles/git.conf
		if [[ -f $HOME/.gitconfig && ! -L $HOME/.gitconfig ]]; then
			install -m 0600 "$HOME/.gitconfig" "$git_config"
		else
			install -m 0600 "$ROOT/.config/dotfiles/git.conf.example" "$git_config"
		fi
	fi

	[[ -e $zipline ]] && chmod 0600 "$zipline"
	wine_line=$(grep -m1 -E '^[[:space:]]*set[[:space:]]+-x[[:space:]]+WINEPREFIX[[:space:]]+' "$fish_config" 2>/dev/null || true)
	if [[ -n $wine_line ]] && ! grep -q 'WINEPREFIX' "$local_fish" 2>/dev/null; then
		if [[ ! -e $local_fish ]]; then
			record_created .config/fish/conf.d/local.fish
			printf '# Machine-local environment.\n' > "$local_fish"
		fi
		printf '%s\n' "$wine_line" >> "$local_fish"
	fi
}

install_prerequisites() {
	step "Install migration prerequisites"
	run sudo pacman -Syu --needed stow ironbar hyprpolkitagent gnome-themes-extra libcec qalculate-gtk yarn
	require_command stow
}

disable_legacy_plugin() {
	if legacy_plugin_enabled; then
		step "Disable legacy native split-monitor-workspaces plugin"
		run hyprpm disable split-monitor-workspaces
	fi
}

pause_live_autoreload() {
	hyprctl getoption misc:disable_autoreload >/dev/null 2>&1 || return
	step "Pause Hyprland automatic reload during cutover"
	hyprctl keyword misc:disable_autoreload true >/dev/null
}

move_target_to_restore_point() {
	local relative=$1 bucket=$2
	local target=$HOME/$relative destination=$CURRENT_POINT/$bucket/$relative
	[[ -e $target || -L $target ]] || return
	install -d -- "$(dirname -- "$destination")"
	mv -- "$target" "$destination"
}

quarantine_targets() {
	local path source target moved=0
	step "Quarantine managed config roots"

	for path in "${LOCAL_PATHS[@]}"; do
		move_target_to_restore_point "$path" carried
	done
	for path in "${USER_PATHS[@]}"; do
		[[ -e $HOME/$path || -L $HOME/$path ]] || continue
		move_target_to_restore_point "$path" displaced
		((moved += 1))
	done
	for path in "${LOCAL_PATHS[@]}"; do
		source=$CURRENT_POINT/carried/$path
		target=$HOME/$path
		[[ -e $source || -L $source ]] || continue
		install -d -- "$(dirname -- "$target")"
		mv -- "$source" "$target"
	done
	printf 'quarantined roots: %d\n' "$moved"
}

restore_legacy_plugin() {
	local point=$1
	[[ -f $point/legacy-plugin-enabled ]] || return 0
	command -v hyprpm >/dev/null || return 0
	hyprpm enable split-monitor-workspaces || warn "could not re-enable legacy split-monitor-workspaces"
	hyprpm reload -n || warn "could not reload HyprPM"
}

restore_user_config() {
	local point=$1 path
	[[ -f $point/user-home.tar.gz ]] || die "missing user archive in $point"

	step "Restore archived user configuration"
	for path in "${USER_PATHS[@]}"; do
		managed_path "$path" || die "unsafe restore path: $path"
		[[ $path != *..* ]] || die "unsafe restore path: $path"
		rm -rf -- "${HOME:?}/$path" || return
	done
	tar --acls --xattrs -C "$HOME" -xzpf "$point/user-home.tar.gz" || return
	restore_legacy_plugin "$point"

	if hyprctl version >/dev/null 2>&1; then
		pkill -x ironbar 2>/dev/null || true
		hyprctl reload || true
		if command -v waybar >/dev/null && ! pgrep -x waybar >/dev/null; then
			nohup waybar > "$point/waybar-restore.log" 2>&1 &
		fi
	fi
	return 0
}

restore_system_config() {
	local point=$1
	local archive=$point/system-sddm.tar.gz
	[[ -f $archive ]] || return 0

	step "Restore archived SDDM configuration"
	sudo rm -f /etc/sddm.conf.d/10-dotfiles-theme.conf /etc/sddm.conf.d/20-dotfiles-virtual-keyboard.conf || return
	sudo rm -rf /usr/share/sddm/themes/sddm-astronaut-theme /var/lib/matugen-sddm || return
	sudo tar --acls --xattrs --overwrite -C / -xzpf "$archive" || return
	[[ ! -d /usr/share/sddm/themes/sddm-astronaut-theme || -x /usr/share/sddm/themes/sddm-astronaut-theme ]]
}

verify_checksums() {
	local point=$1
	[[ -f $point/COMPLETE && -f $point/SHA256SUMS ]] || die "incomplete restore point: $point"
	[[ -O $point && -O $point/user-home.tar.gz ]] || die "restore point is not owned by the current user: $point"
	(cd "$point" && sha256sum -c SHA256SUMS)
	while IFS= read -r path; do
		[[ $path != /* && $path != *../* ]] || die "unsafe user archive member: $path"
		managed_path "${path%/}" || die "unexpected user archive member: $path"
	done < <(tar -tzf "$point/user-home.tar.gz")
	if [[ -f $point/system-sddm.tar.gz ]]; then
		while IFS= read -r path; do
			[[ $path != /* && $path != *../* ]] || die "unsafe system archive member: $path"
			case $path in
			etc/sddm.conf.d/*|usr/share/sddm/themes/sddm-astronaut-theme/*|var/lib/matugen-sddm/*) ;;
			*) die "unexpected system archive member: $path" ;;
			esac
		done < <(tar -tzf "$point/system-sddm.tar.gz")
	fi
}

activate_live_session() {
	local point=$1 errors
	hyprctl version >/dev/null 2>&1 || return

	step "Activate v3 in the live Hyprland session"
	hyprctl reload
	errors=$(hyprctl configerrors)
	[[ -z $errors ]] || die "Hyprland config errors: $errors"

	if ! pgrep -x ironbar >/dev/null; then
		nohup ironbar > "$point/ironbar.log" 2>&1 &
		sleep 1
	fi
	pgrep -x ironbar >/dev/null || die "Ironbar did not stay running; see $point/ironbar.log"
	pkill -x waybar 2>/dev/null || true

	pkill -x swaync 2>/dev/null || true
	nohup swaync > "$point/swaync.log" 2>&1 &
	pkill -x swayosd-server 2>/dev/null || true
	nohup swayosd-server > "$point/swayosd.log" 2>&1 &
	if ! pgrep -x hypridle >/dev/null; then
		nohup hypridle > "$point/hypridle.log" 2>&1 &
	fi
	systemctl --user start hyprpolkitagent.service || warn "could not start hyprpolkitagent.service"
}

verify_migration() {
	local total linked missing conflicts errors
	step "Verify migration"
	read -r total linked missing conflicts < <(audit_targets)
	printf 'managed files: %d; linked: %d; missing: %d; conflicts: %d\n' \
		"$total" "$linked" "$missing" "$conflicts"
	((conflicts == 0)) || die "managed target conflicts remain"
	((missing == 0)) || die "managed targets are missing"
	[[ -f $HOME/.config/dotfiles/machine.lua ]] || die "missing machine.lua"
	[[ -f $HOME/.config/dotfiles/git.conf ]] || die "missing git.conf"
	git config user.name >/dev/null || die "Git user.name is unavailable"
	git config user.email >/dev/null || die "Git user.email is unavailable"

	if command -v Hyprland >/dev/null; then
		DOTFILES_VERIFY_CONFIG=1 Hyprland --verify-config -c "$HOME/.config/hypr/hyprland.lua" >/dev/null
	fi
	if hyprctl version >/dev/null 2>&1; then
		errors=$(hyprctl configerrors)
		[[ -z $errors ]] || die "Hyprland config errors: $errors"
	fi
	printf 'verification: ok\n'
}

on_error() {
	local status=$? restore_status=0
	trap - ERR
	set +e
	printf '\nMigration failed (exit %d).\n' "$status" >&2
	if $CUTOVER_STARTED && [[ -n $CURRENT_POINT && -f $CURRENT_POINT/COMPLETE ]]; then
		warn "restoring the archived user and system configuration automatically"
		restore_user_config "$CURRENT_POINT" || restore_status=1
		restore_system_config "$CURRENT_POINT" || restore_status=1
		if ((restore_status)); then
			warn "automatic restoration was incomplete; run '$ROOT/migrate-v3.sh restore $CURRENT_POINT'"
		else
			warn "archived user and system configuration restored"
		fi
	fi
	exit "$status"
}

migrate() {
	preflight
	if $DRY_RUN; then
		step "Installer dry run"
		"$ROOT/install.sh" --dry-run
		printf '\nDry run complete; no files were changed.\n'
		return
	fi

	confirm "Create a restore point and migrate this machine to v3?"
	sudo -v
	create_restore_point
	printf 'restore point: %s\n' "$CURRENT_POINT"

	install_prerequisites
	CUTOVER_STARTED=true
	trap on_error ERR
	pause_live_autoreload
	prepare_local_overrides
	disable_legacy_plugin
	quarantine_targets

	step "Apply v3 dotfiles"
	"$ROOT/bootstrap.sh"

	step "Complete v3 installation"
	"$ROOT/install.sh"
	activate_live_session "$CURRENT_POINT"
	verify_migration
	: > "$CURRENT_POINT/MIGRATED"
	CUTOVER_STARTED=false
	trap - ERR
	printf '\nMigration complete. Restore point: %s\n' "$CURRENT_POINT"
}

list_restore_points() {
	local point found=false
	[[ -d $STATE_ROOT ]] || { printf 'No restore points.\n'; return; }
	for point in "$STATE_ROOT"/[0-9]*; do
		[[ -d $point && -f $point/COMPLETE ]] || continue
		found=true
		printf '%s%s\n' "$point" "$([[ -f $point/MIGRATED ]] && printf '  [migrated]' || true)"
	done
	$found || printf 'No complete restore points.\n'
}

resolve_restore_point() {
	local requested=${1:-latest} point state_root_real
	if [[ $requested == latest ]]; then
		point=$(readlink -f -- "$STATE_ROOT/latest" 2>/dev/null || true)
	elif [[ $requested == /* ]]; then
		point=$requested
	else
		point=$STATE_ROOT/$requested
	fi
	[[ -n $point && -d $point ]] || die "restore point not found: $requested"
	point=$(readlink -f -- "$point")
	state_root_real=$(readlink -f -- "$STATE_ROOT")
	[[ $point == "$state_root_real"/* ]] || die "restore point must be inside $STATE_ROOT"
	printf '%s\n' "$point"
}

restore() {
	local point
	point=$(resolve_restore_point "${1:-latest}")
	verify_checksums "$point"
	if $DRY_RUN; then
		printf 'Would restore: %s\n' "$point"
		tar -tzf "$point/user-home.tar.gz" | sed -n '1,80p'
		return
	fi

	confirm "Restore $point and replace the current v3 user/SDDM configuration?"
	restore_user_config "$point"
	restore_system_config "$point"
	printf '\nRestore complete. Log out and back in if the live shell did not fully refresh.\n'
}

COMMAND=${1:-}
[[ -n $COMMAND ]] || { usage; exit 1; }
[[ $COMMAND != -h && $COMMAND != --help ]] || { usage; exit 0; }
shift
POSITIONAL=()
while (($#)); do
	case $1 in
	--dry-run) DRY_RUN=true ;;
	--yes) ASSUME_YES=true ;;
	-h|--help) usage; exit 0 ;;
	*) POSITIONAL+=("$1") ;;
	esac
	shift
done

case $COMMAND in
check)
	((${#POSITIONAL[@]} == 0)) || die "check takes no arguments"
	preflight
	;;
migrate)
	((${#POSITIONAL[@]} == 0)) || die "migrate takes only --dry-run and --yes"
	migrate
	;;
list)
	((${#POSITIONAL[@]} == 0)) || die "list takes no arguments"
	list_restore_points
	;;
restore)
	((${#POSITIONAL[@]} <= 1)) || die "restore takes at most one restore point"
	restore "${POSITIONAL[0]:-latest}"
	;;
*)
	usage
	die "unknown command: $COMMAND"
	;;
esac
