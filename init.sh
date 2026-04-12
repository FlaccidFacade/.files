#!/usr/bin/env bash

set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
INSTALL_TOOLS=false

usage() {
	cat <<'EOF'
Usage: ./init.sh [--install-tools] [--force] [--help]

Applies dotfiles from this repo by backing up and symlinking:
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

backup_if_needed() {
	local target="$1"
	if [[ -e "$target" && ! -L "$target" ]]; then
		mv "$target" "${target}.backup.${TIMESTAMP}"
		echo "Backed up $target -> ${target}.backup.${TIMESTAMP}"
	fi
}

link_file() {
	local source_file="$1"
	local target_file="$2"

	if [[ -L "$target_file" ]]; then
		local linked_to
		linked_to="$(readlink "$target_file")"
		if [[ "$linked_to" == "$source_file" ]]; then
			echo "Already linked: $target_file"
			return
		fi
	fi

	if [[ -e "$target_file" || -L "$target_file" ]]; then
		if [[ "$FORCE" == true ]]; then
			rm -rf "$target_file"
		else
			backup_if_needed "$target_file"
			if [[ -e "$target_file" || -L "$target_file" ]]; then
				rm -rf "$target_file"
			fi
		fi
	fi

	ln -s "$source_file" "$target_file"
	echo "Linked $target_file -> $source_file"
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

link_file "$REPO_DIR/.bashrc" "$HOME/.bashrc"
link_file "$REPO_DIR/.gitconfig" "$HOME/.gitconfig"

if [[ "$INSTALL_TOOLS" == true ]]; then
	install_tools
fi

echo "Done. Start a new shell or run: source ~/.bashrc"
