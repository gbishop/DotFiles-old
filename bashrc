# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
# ... and ignore same sucessive entries.
export HISTCONTROL=ignoreboth

# set the EDITOR variable so I'm in control
export EDITOR=vim

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
#shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

PS1='$ '
if [ -f /usr/bin/git ]; then
    export GIT_PS1_SHOWDIRTYSTATE=true
    export GIT_PS1_SHOWUNTRACKEDFILES=true
    if [ -f /etc/bash_completion.d/git ]; then
        . /etc/bash_completion.d/git
    fi
    case "$TERM" in
    xterm)
        export PS1='\[\033[00;34m\]\W\[\033[00;31m\]`__git_ps1`\[\033[00m\]\$ '
        ;;
    *)
        export PS1='\W`__git_ps1`$ '
        ;;
    esac
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
    ;;
*)
    ;;
esac

# Alias definitions.
alias ls='ls -F'
alias more=less
alias sshl="/usr/bin/ssh -o PreferredAuthentications=password"
alias scpl="/usr/bin/scp -o PreferredAuthentications=password"

calc(){ awk "BEGIN{ print $* }" ;}

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

