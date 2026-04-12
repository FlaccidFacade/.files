# .files

Minimal dotfiles repo with 3 files:

- `.bashrc`: interactive shell settings and aliases
- `.gitconfig`: git identity and aliases
- `init.sh`: bootstrap script to apply dotfiles on a fresh machine

## Quick start

```bash
git clone https://github.com/FlaccidFacade/.files.git ~/.files
cd ~/.files
chmod +x init.sh
./init.sh
```

This will:

- backup existing `~/.bashrc` and `~/.gitconfig` (timestamped)
- symlink both files from this repo into your home directory

## Optional: install common tools

```bash
sudo ./init.sh --install-tools
```

Installs: git, docker, docker-compose, python3 (+ pip/venv), vim, and gh.

## Useful flags

```bash
./init.sh --help
./init.sh --force
```

- `--force` removes/replaces existing target files without keeping them in place
- without `--force`, regular files are backed up before being replaced


