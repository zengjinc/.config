alias cds='cd /home/jingle/data/jhgame/server_git/'
alias proxy=proxychains
alias ra=ranger

# tmux
alias tn='tmux new -s'
alias ta='tmux attach -t'
alias tk='tmux kill-session -t'

if [ -f /home/jingle/.svn_commit_check.sh ]; then
    alias svn="/home/jingle/.svn_commit_check.sh $@"
fi

if [ -f /home/jingle/.git_commit_check.sh ]; then
    alias git="/home/jingle/.git_commit_check.sh $@"
fi

alias fd='
	find ~/data/jhgame/data/fanli_dev/excel/ -name "*.xlsx" \
	| fzf --bind "enter:execute-silent(et {} &)+abort,left-click:execute-silent(et {} &)+abort"
'
# 远程连接win桌面
alias rdp='rdesktop -g 1920x1080 -a 16 -u junhai 172.16.50.211'

