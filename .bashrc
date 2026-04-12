# ─────────────────────────────────────────────────────────────────────────────
# ~/.bashrc  –  optimized developer shell configuration
# ─────────────────────────────────────────────────────────────────────────────

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ─── History ─────────────────────────────────────────────────────────────────
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups   # ignore duplicates and lines starting with space
HISTTIMEFORMAT="%F %T  "
shopt -s histappend                # append instead of overwrite
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# ─── Shell options ────────────────────────────────────────────────────────────
shopt -s checkwinsize              # update LINES/COLUMNS after each command
shopt -s cdspell                   # auto-correct minor cd typos
shopt -s autocd                    # type a directory name to cd into it
shopt -s globstar                  # ** glob pattern
set -o noclobber                   # don't overwrite files with >  (use >| to force)

# ─── Color support ───────────────────────────────────────────────────────────
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# ─── Prompt ───────────────────────────────────────────────────────────────────
# Shows: user@host:dir (git branch) $
_git_prompt() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
    printf " \001\033[0;36m\002(%s)\001\033[0m\002" "$branch"
}

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(_git_prompt) \$ '

# ─── ls / directory aliases ───────────────────────────────────────────────────
alias ls='ls --color=auto'
alias l='ls -al'
alias ll='ls -al'
alias la='ls -A'
alias lt='ls -altr'          # sort by time, newest last

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# cl = go up one directory and immediately list it
cl() {
    cd .. && ll
}

# ─── Navigation helpers ───────────────────────────────────────────────────────
alias -- -='cd -'            # cd to previous directory

# ─── Safety nets ─────────────────────────────────────────────────────────────
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# ─── General utilities ────────────────────────────────────────────────────────
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias less='less -R'
alias ppath='echo -e "${PATH//:/\\n}"'   # print PATH entries one per line

# ─── Docker  (d / dc) ─────────────────────────────────────────────────────────
alias d='docker'
alias dc='docker-compose'
alias v='vim'
alias py='python3'
alias py3='python3'


# ─── Git  (g + --global aliases) ───────────────────────────────────────────────────
# 'g' is git; 'g <alias>' 
alias g='git'

# make bash complete 'g' the same way it completes 'git'
if command -v __git_complete &>/dev/null; then
    __git_complete g __git_main
elif [ -f /usr/share/bash-completion/completions/git ]; then
    source /usr/share/bash-completion/completions/git
    __git_complete g __git_main 2>/dev/null || true
fi

# ─── Load local overrides ─────────────────────────────────────────────────────
# Put machine-specific settings in ~/.bashrc.local  (not committed to git)
[ -f ~/.bashrc.local ] && source ~/.bashrc.local
