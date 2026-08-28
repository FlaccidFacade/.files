#!/usr/bin/env bash

set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
INSTALL_TOOLS=false

usage() {
	cat <<'EOF'
Usage: ./init.sh [--install-tools] [--force] [--help]

Applies dotfiles from this repo by appending them to the following files in the user's home directory:
	- .bashrc
	- .gitconfig

Options:
	--install-tools   Install common tools (git, docker, docker compose, python3, vim, gh)
	--force           Replace existing files without prompt
	--help            Show this help
EOF
}

FORCE=false
while [[ $# -gt 0 ]]; do
	case "$1" in
		--install-tools)
			INSTALL_TOOLS=true
			shift
			;;
		--force)
			FORCE=true
			shift
			;;
		--help|-h)
			usage
			exit 0
			;;
		*)
			echo "Unknown option: $1" >&2
			usage
			exit 1
			;;
	esac
done

backup() {
	local target="$1"
	if [[ -e "$target" && ! -L "$target" ]]; then
		cp "$target" "${target}.backup.${TIMESTAMP}"
		echo "Backed up $target -> ${target}.backup.${TIMESTAMP}"
	fi
}

remove_link() {
	local target="$1"
	if [[ -L "$target" ]]; then
		rm "$target"
		echo "Removed symlink: $target"
	fi
}

append_file() {
	local source_file="$1"
	local target_file="$2"
	backup "$target_file"
	remove_link "$target_file"
    cat "$source_file" >> "$target_file"
	echo "Appended $target_file with $source_file"
}

install_tools() {
	local target_user

	if [[ "${EUID}" -ne 0 ]]; then
		echo "--install-tools requires root (run with sudo)." >&2
		exit 1
	fi

	target_user="${SUDO_USER:-${USER:-root}}"

	echo "Installing packages..."
	apt-get update
	apt-get install -y git docker.io docker-compose python3 python3-pip python3-venv vim gh

	if [[ -n "$target_user" ]] && ! id -nG "$target_user" 2>/dev/null | grep -qw docker; then
		usermod -aG docker "$target_user" 2>/dev/null || true
	fi

	systemctl enable docker || true
	systemctl start docker || true

	command -v python >/dev/null 2>&1 || ln -sf /usr/bin/python3 /usr/bin/python
	command -v pip >/dev/null 2>&1 || ln -sf /usr/bin/pip3 /usr/bin/pip
}

echo "Applying dotfiles from: $REPO_DIR"
append_file "$REPO_DIR/_.bashrc" "$HOME/.bashrc"
append_file "$REPO_DIR/_.gitconfig" "$HOME/.gitconfig"

if [[ "$INSTALL_TOOLS" == true ]]; then
	install_tools
fi

# Auto-run any executable scripts in scripts/
SCRIPTS_DIR="$REPO_DIR/scripts"
if [[ -d "$SCRIPTS_DIR" ]]; then
	for script in "$SCRIPTS_DIR"/*.sh; do
		[[ -f "$script" && -x "$script" ]] || continue
		echo "Running: $(basename "$script")"
		"$script" || echo "Warning: $script exited with code $?"
	done
else
	echo "No scripts/ directory found, skipping."
fi

echo "Done. Start a new shell or run: source ~/.bashrc"
