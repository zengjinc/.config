#!/usr/bin/env bash

cur=$(pwd)

if [ -d $cur/.git ]; then
  ~/.git_commit_check.sh $@
elif [ -d $cur/.svn ]; then
  ~/.svn_commit_check.sh $@
else
 echo -e "\e[92m=> Not a vcs repo \e[0;0m " 
fi
