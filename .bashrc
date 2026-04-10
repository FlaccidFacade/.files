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
alias path='echo -e "${PATH//:/\\n}"'   # print PATH entries one per line

# ─── Docker  (d / dc) ─────────────────────────────────────────────────────────
alias d='docker'
alias dc='docker-compose'

# common docker shortcuts
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dstop='docker stop'
alias dprune='docker system prune -f'

# common docker-compose shortcuts
alias dcu='docker-compose up'
alias dcud='docker-compose up -d'
alias dcd='docker-compose down'
alias dcb='docker-compose build'
alias dcl='docker-compose logs -f'
alias dcr='docker-compose restart'

# ─── Git  (g + sub-aliases) ───────────────────────────────────────────────────
# 'g' on its own runs git; 'g <alias>' expands to the full git command so that
# tab-completion and git's own alias machinery both keep working.
g() {
    # map short aliases to git sub-commands / flags
    case "$1" in
        # ── status & info ──────────────────────────────────────
        s)   shift; git status "$@" ;;
        ss)  shift; git status -s "$@" ;;
        lg)  shift; git log --oneline --graph --decorate "$@" ;;
        lga) shift; git log --oneline --graph --decorate --all "$@" ;;
        lgf) shift; git log --stat "$@" ;;
        # ── branching & checkout ──────────────────────────────
        co)  shift; git checkout "$@" ;;
        cob) shift; git checkout -b "$@" ;;
        br)  shift; git branch "$@" ;;
        bra) shift; git branch -a "$@" ;;
        brd) shift; git branch -d "$@" ;;
        brD) shift; git branch -D "$@" ;;
        sw)  shift; git switch "$@" ;;
        swc) shift; git switch -c "$@" ;;
        # ── remotes ───────────────────────────────────────────
        f)   shift; git fetch "$@" ;;
        fa)  shift; git fetch --all --prune "$@" ;;
        p)   shift; git pull "$@" ;;
        pr)  shift; git pull --rebase "$@" ;;
        pu)  shift; git push "$@" ;;
        puf) shift; git push --force-with-lease "$@" ;;
        puu) shift; git push -u origin HEAD "$@" ;;
        # ── staging & committing ──────────────────────────────
        a)   shift; git add "$@" ;;
        aa)  shift; git add -A "$@" ;;
        ap)  shift; git add -p "$@" ;;
        c)   shift; git commit "$@" ;;
        cm)  shift; git commit -m "$@" ;;
        ca)  shift; git commit --amend "$@" ;;
        can) shift; git commit --amend --no-edit "$@" ;;
        # ── diff & stash ──────────────────────────────────────
        d)   shift; git diff "$@" ;;
        ds)  shift; git diff --staged "$@" ;;
        st)  shift; git stash "$@" ;;
        stp) shift; git stash pop "$@" ;;
        stl) shift; git stash list "$@" ;;
        # ── rebase & merge ────────────────────────────────────
        rb)  shift; git rebase "$@" ;;
        rbi) shift; git rebase -i "$@" ;;
        rbc) shift; git rebase --continue "$@" ;;
        rba) shift; git rebase --abort "$@" ;;
        mg)  shift; git merge "$@" ;;
        # ── reset & clean ─────────────────────────────────────
        rs)  shift; git reset "$@" ;;
        rsh) shift; git reset --hard "$@" ;;
        gcl) shift; git clean -fd "$@" ;;
        # ── tags ──────────────────────────────────────────────
        t)   shift; git tag "$@" ;;
        # ── remote ────────────────────────────────────────────
        rv)  shift; git remote -v "$@" ;;
        # ── catch-all: pass straight through to git ───────────
        *)   git "$@" ;;
    esac
}

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
