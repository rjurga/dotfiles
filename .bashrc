# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias tree='tree -C'

if [ -x /usr/bin/nvim ]; then
    alias vim='nvim'
fi

# Also alias expand the next word after sudo
alias sudo='sudo '

PS1='[\u@\h \W]\$ '
