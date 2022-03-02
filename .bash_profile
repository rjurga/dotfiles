export HISTCONTROL=ignoreboth
export HISTSIZE=32768

# Neovim

if [ -x /usr/bin/nvim ]; then
    VIM_BIN=nvim
else
    VIM_BIN=vim
fi
export SUDO_EDITOR=${VIM_BIN}
export VISUAL=${VIM_BIN}
export EDITOR=${VIM_BIN}
export DIFFPROG="${VIM_BIN} -d"
unset VIM_BIN

# Plasma

if [ "$(tty)" = "/dev/tty1" ] && [ -x /usr/bin/startplasma-wayland ]; then
    exec startplasma-wayland
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
