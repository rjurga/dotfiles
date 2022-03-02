# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Tomorrow Night theme by Chris Kempson (http://chriskempson.com)
color_background="29;31;33"
color_current_line="40;42;46"
color_selection="55;59;65"
color_foreground="197;200;198"
color_comment="150;152;150"
color_red="204;102;102"
color_orange="222;147;95"
color_yellow="240;198;116"
color_green="181;189;104"
color_aqua="138;190;183"
color_blue="129;162;190"
color_purple="178;148;187"

set_fg_color() { printf '\001\033[38;2;%sm\002' $1; }
set_bg_color() { printf '\001\033[48;2;%sm\002' $1; }
set_bold="\[\033[1m\]"
reset_attributes="\[\033[0m\]"

PS1="$(set_fg_color $color_comment)[$(set_fg_color $color_orange)\u$(set_fg_color $color_comment)@$(set_fg_color $color_purple)\h $(set_fg_color $color_comment)\w]$(set_fg_color $color_orange)$set_bold\$$reset_attributes "
PS2="$(set_fg_color $color_orange)$set_bold>$reset_attributes "

unset -f set_fg_color
unset -f set_bg_color
unset set_bold
unset reset_attributes

unset color_background
unset color_current_line
unset color_selection
unset color_foreground
unset color_comment
unset color_red
unset color_orange
unset color_yellow
unset color_green
unset color_aqua
unset color_blue
unset color_purple

alias ls='ls --color=auto'
alias sudo='sudo '
alias tree='tree -C'

if [ -x /usr/bin/nvim ]; then
    alias vim='nvim'
fi

