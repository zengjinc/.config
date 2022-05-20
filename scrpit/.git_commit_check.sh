#!/bin/bash
 
if [ "$1" = "up" ] || [ "$1" = "sync" ] || [ "$1" = "push" ]; then
    # 更新或提交代码时，工作区有改动先stash
    if [ -n "$(git status -s | grep -v ??)" ]; then
        git stash
        git $@
        git stash pop
    else
        git $@
    fi 
elif [ "$1" = "add" ] && [ "$2" == "." ]; then
   # 不提交script目录下的文件
   git $@
   git rh src/lib/proto_rpc/client_mock.erl
elif [ "$1" = "slg" ]; then
   git lg --author="chenzengjin\|fengzhenlin\|huangxiaoming"	
else
    git $@
fi

