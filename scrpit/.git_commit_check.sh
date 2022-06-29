#!/bin/bash

GIT=/usr/bin/git

if [ "$1" = "up" ] || [ "$1" = "sync" ] || [ "$1" = "push" ]; then
    # 更新或提交代码时，工作区有改动先stash
    if [ -n "$($GIT status -s | grep -v ??)" ]; then
        $GIT stash
        $GIT $@
        $GIT stash pop
    else
        $GIT $@
    fi 
elif [ "$1" = "add" ] && [ "$2" == "." ]; then
   # 不提交script目录下的文件
   $GIT $@
   $GIT rh src/lib/proto_rpc/client_mock.erl
elif [ "$1" = "slg" ]; then
   $GIT lg --author="chenzengjin\|fengzhenlin\|huangxiaoming\|刘伟朝"	
else
    $GIT $@
fi

