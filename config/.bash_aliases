alias cds='cd ~/data/jhgame/server_git/'
alias ra=ranger
alias s='vc st'

# tmux
alias t='tmux new -s dev -n dev'
alias tn='tmux new -s'
alias ta='tmux attach -t'
alias tk='tmux kill-session -t'

if [ -f ~/.vcs_auto.sh ]; then
    alias vc="~/.vcs_auto.sh $@"
fi

if [ -f ~/.svn_commit_check.sh ]; then
    alias svn="~/.svn_commit_check.sh $@"
fi

if [ -f ~/.git_commit_check.sh ]; then
    alias git="~/.git_commit_check.sh $@"
fi

alias fd='
	find ~/data/jhgame/data/mailiang_dev/excel/ -name "*.xlsx" \
	| fzf --bind "enter:execute-silent(et {} &)+abort,left-click:execute-silent(et {} &)+abort"
'
# 远程连接win桌面
alias rdp='rdesktop -g 1920x1080 -a 16 -u junhai 172.16.50.211'

# git使用指定策略合并
gct() {
	git checkout --theirs $1 && git add $1 && git status;
}

# git使用指定策略合并
gco() {
	git checkout --ours $1 && git add $1 && git status;
}

# kill vscode 进程
killcode() {
	ps -ef | grep .vscode-server | awk '{print $2}' | xargs kill -9
}
