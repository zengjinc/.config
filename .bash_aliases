alias cds='cd /home/jingle/data/jhgame/server_git/'
alias proxy=proxychains
alias ra=ranger

if [ -f /home/jingle/.svn_commit_check.sh ]; then
    alias svn="/home/jingle/.svn_commit_check.sh $@"
fi

if [ -f /home/jingle/.git_commit_check.sh ]; then
    alias git="/home/jingle/.git_commit_check.sh $@"
fi

alias jump='zssh -X -i ~/.ssh/id_rsa -p 2222 chenzengjin@134.175.229.26'
alias fd='find ~/data/jhgame/data/fanli_dev/excel/ -name "*.xlsx" | fzf --bind "enter:execute-silent(et {} &)+abort,left-click:execute-silent(et {} &)+abort"'
