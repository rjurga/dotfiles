export HISTCONTROL=ignoreboth
export HISTSIZE=50000

# Neovim

export SUDO_EDITOR=nvim
export VISUAL=nvim
export EDITOR=nvim
export DIFFPROG="nvim -d"

# Plasma

if [ "$(tty)" = "/dev/tty1" ] && [ -x /usr/bin/startplasma-wayland ]; then
    exec startplasma-wayland
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
