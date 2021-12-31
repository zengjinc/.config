# Setup fzf
# ---------
if [[ ! "$PATH" == */home/jingle/data/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/jingle/data/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/jingle/data/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/home/jingle/data/.fzf/shell/key-bindings.bash"

# 搜索布局
export FZF_DEFAULT_OPTS='--height 50% --reverse'
