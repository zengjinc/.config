
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

PS1='\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]$(parse_git_branch)\[\033[00m\]\$ '

export EDITOR=vim

# alacritty
. "$HOME/.cargo/env"
source ~/.config/alacritty/alacritty

# man 页面颜色
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'
export PAGER=less

# powerline
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. /usr/share/powerline/bindings/bash/powerline.sh

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# z.sh
#[ -f ~/z.sh ] && source ~/z.sh

# rebar3
[ -d ~/.cache/rebar3/bin ] && export PATH=$PATH:~/.cache/rebar3/bin 

