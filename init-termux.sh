#!/usr/bin/env bash

set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
INSTALL_TOOLS=false

usage() {
	cat <<'EOF'
Usage: ./init-termux.sh [--install-tools] [--force] [--help]

Applies dotfiles from this repo by appending them to the following files in the user's home directory:
	- .bashrc
	- .gitconfig

Options:
	--install-tools   Install common tools (git, python, vim, gh)
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
	echo "Installing packages..."
	
	# Update pkg repository and install packages
	if command -v pkg >/dev/null 2>&1; then
		pkg update -y
		# In Termux, python includes pip and venv. Installing gh, vim, python, git.
		# Fallback packages included if names vary/change.
		pkg install -y git python vim gh || pkg install -y git python3 vim github-cli || true
	elif command -v apt-get >/dev/null 2>&1; then
		apt-get update
		apt-get install -y git python3 vim gh || apt-get install -y git python3 vim github-cli || true
	else
		echo "No supported package manager found (pkg or apt-get)." >&2
		exit 1
	fi

	# Ensure python and pip command/symlink exist if names vary/change
	if ! command -v python >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
		ln -sf "$(command -v python3)" "$(dirname "$(command -v python3)")/python"
	fi
	if ! command -v pip >/dev/null 2>&1 && command -v pip3 >/dev/null 2>&1; then
		ln -sf "$(command -v pip3)" "$(dirname "$(command -v pip3)")/pip"
	fi
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
		# Exclude scripts not suitable for Termux on phone/tablets
		if [[ "$(basename "$script")" == "setup-gnome-shortcuts.sh" ]]; then
			echo "Skipping: setup-gnome-shortcuts.sh (not supported on Termux)"
			continue
		fi
		echo "Running: $(basename "$script")"
		"$script" || echo "Warning: $script exited with code $?"
	done
else
	echo "No scripts/ directory found, skipping."
fi

echo "Done. Start a new shell or run: source ~/.bashrc"
