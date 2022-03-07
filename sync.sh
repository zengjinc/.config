cp -r ~/.config/alacritty/* alacritty/ \
&& cp ~/.bash_aliases config/ \
&& cp ~/.bash_profile config/ \
&& cp ~/.bashrc config/ \
&& cp ~/.fzf.bash config/ \
&& cp ~/.gitignore_global config/ \
&& cp ~/.svnignore_global config/ \
&& cp ~/.tmux.conf config/ \
\
&& cp ~/data/jhgame/server_git/elvis.config erl_config/ \
&& cp ~/data/jhgame/server_git/erlang_ls.config erl_config/ \
&& cp ~/.config/rebar3/rebar.config erl_config/ \
\
&& cp -r ~/data/typora/* note/ \
\
&& cp -r ~/.config/powerline/* powerline/ \
\
&& cp ~/data/jhgame/dev.sh scrpit/ \
&& cp ~/.git_commit_check.sh scrpit/ \
&& cp ~/.git-prompt.sh scrpit/ \
&& cp ~/.resolution_auto.sh scrpit/ \
&& cp ~/.svn_commit_check.sh scrpit/ \
&& cp ~/.vcs_auto.sh scrpit/ \
&& cp ~/bdown.sh scrpit/ \
\
&& git add . \
&& git commit -m sync \
&& git push
