#!/usr/bin/env bash
#-------------------------------------------------
# 工具包主脚本
#-------------------------------------------------

# 获取脚本文件所在绝对路径(自动跟踪符号链接)
get_real_path(){
    local source="${BASH_SOURCE[0]}"
    while [ -h "$source" ]; do
        local dir="$( cd -P "$( dirname "$source" )" && pwd )"
        source="$( readlink "$source" )"
        [[ $source != /* ]] && source="$dir/$source"
    done
    echo "$( cd -P "$( dirname "$source" )" && pwd )"
}

# 定义
ROOT=$(get_real_path)
SCRIPT_PATH=$ROOT/script
declare -A DOC 
declare -A ARG
TMUX_WIN_NO=1


# 检测某个函数是否已经定义
is_fun_exists(){
    declare -F "$1" > /dev/null; return $?
}

# 检测某个命令是否存在
is_command_exists(){
    command -v $1 >/dev/null; return $?
}

# 判定是否为整数
is_integer(){
    local re='^[0-9]+$'
    [[ $1 =~ $re ]]; return $?
}

# 检查数组中是否存在某个元素
# 参数1：数组
# 参数2: 元素
# 使用示例: in_array elems[@] $elem
in_array(){
    declare -a haystack=("${!1}")
    local needle=${2}
    for v in ${haystack[@]}; do
        if [[ ${v} == ${needle} ]]; then
            return 0
        fi
    done
    return 1
}

# 输出一条普通信息
INFO(){
    echo -e "\e[92m=>\e[0;0m ${1}"
}

# 输出一条错误信息
ERR(){
    >&2 echo -e "\e[91m>>\e[0;0m ${1}"
}

# 检查锁
lock_check(){
    local task=$1
    local msg=$2
    lock=/tmp/unity_running_xc2_${task}.lock
    if [ -f $lock ]; then
        taskname=$(<$lock)
        ERR "Unity正在执行\"$taskname\"任务，需等待该任务完成..."
        exit 1
    fi
    touch $lock # 加锁
    echo $msg > $lock
}

# 解锁
lock_release(){
    local task=$1
    lock=/tmp/unity_running_xc2_${task}.lock
    rm -f $lock
}

# 输出命令行补全信息
fun_completion(){
    echo $(declare -p DOC)
}

# 
update_tmux_win_no(){
	TMUX_WIN_NO=$[$(tmux list-window -t dev 2>&1 | wc -l) + 1]
}

DOC[test]="测试方法"
fun_test(){
    echo $ROOT
	#test="$( find $ROOT/server_git -maxdepth 3 -type d | fzf )"
	#test=(( $(tmux list-window -t dev 2>&1 | wc -l)+1 ))
	#test=$[$(tmux list-window -t dev 2>&1 | wc -l) + 1]
	#test=$(date +%H)
	#if [ $test == 14 ]; then
	#	echo "equal"
	#fi
	#echo $test
	#change_t=$(stat -c %Z dev.sh)
	#last_t=$(cat hot_time.txt)
	#echo $change_t
	#echo $last_t
	no=
	echo $no
}

DOC[up_all]="更新所有的源码仓库,所有分支"
fun_up_all(){
    for v in ${ROOT}/*; do
        if is_exclude $(basename $v); then
            #INFO "skip $(basename $v)"
            continue
        elif [ -d $v/.git ]; then
            echo ---------------------------------------------
            INFO "更新仓库: \e[92m$(basename $v)\e[0;0m"
            cd $v
            if [ -n "$(git status -s | grep -v ??)" ]
                then
                    # INFO "工作区有改动"
                    git stash -q
                    pull_all_branch
                    git stash pop -q
                else
                    pull_all_branch
            fi
        elif [ -d $v/.svn ]; then
            echo ---------------------------------------------
            INFO "更新仓库: \e[92m$(basename $v)\e[0;0m"
            # 使用默认策略 theirs-full 用版本库覆盖本地修改
            cd $v && svn update --accept tf
        fi
    done
}

DOC[up]="更新所有的源码仓库,当前分支"
fun_up(){
    for v in ${ROOT}/*; do
        if is_exclude $(basename $v); then
            #INFO "skip $(basename $v)" 
			continue
        elif [ -d $v/.git ]; then
            echo ---------------------------------------------
            INFO "更新仓库: \e[92m$(basename $v)\e[0;0m"
            cd $v
            if [ -n "$(git status -s | grep -v ??)" ]
                then
                    # INFO "工作区有改动"
                    git stash -q
                    git up
                    git stash pop -q
                else
                    git up
            fi
        elif [ -d $v/.svn ]; then
            echo ---------------------------------------------
            INFO "更新仓库: \e[92m$(basename $v)\e[0;0m"
            # 使用默认策略 theirs-full 用版本库覆盖本地修改
            cd $v && svn update --accept tf
        fi
    done
}


# 排除指定仓库
is_exclude(){
    name=$1
    exclude_repo=(9377data 9377proto 9377server)
    for i in ${exclude_repo[*]}; do
        if [[ $i == $name ]]; then
           return 0
        fi
    done
    return 1
}

# 更新git所有分支
pull_all_branch(){
    git branch | awk 'BEGIN{}{if($1=="*"){current=substr($0,3)};print a"git checkout "substr($0,3);print "git up";}END{print "git checkout " current}' | sh
}

DOC[st]="查看仓库状态"
fun_st(){
    for v in ${ROOT}/*; do
        if is_exclude $(basename $v); then
            continue
        elif [ -d $v/.git ]; then
            cd $v
            if [ -n "$(git status -s)" ]; then
                    echo ---------------------------------------------
                    INFO "仓库状态: \e[92m$(basename $v)\e[0;0m"
                    git status -s
            fi
        elif [ -d $v/.svn ]; then
            cd $v
            if [ -n "$(svn st)" ]; then
                    echo ---------------------------------------------
                    INFO "仓库状态: \e[92m$(basename $v)\e[0;0m"
                    svn st
            fi
        fi
    done
    echo ""
}

DOC[gen_data]="调用生成数据脚本"
ARG[gen_data]="[RepoVersion]"
fun_gen_data(){
    if [ -e "${ROOT}/data/${1}/run.sh" ]; then
		path="${ROOT}/data/${1}"
	else
		# 默认
		path="${ROOT}/data/mailiang_dev"
    fi
	INFO "version:${path}"
    cd ${path} && ./run.sh $@ && rm -rf tabletool/Logs/LogExcelHead
}

DOC[gen_proto]="调用生成协议脚本"
ARG[gen_proto]="[RepoVersion]"
fun_gen_proto(){
	if [ -e "${ROOT}/proto/${1}/run.sh" ]; then
		path="${ROOT}/proto/${1}"
	else
		# 默认
		path="${ROOT}/proto/mailiang"
    fi
	INFO "version:${path}"
    cd ${path} && ./run.sh $@
}

DOC[srv_start]="启动游戏服务"
fun_srv_start(){
	cur_win_no=$( tmux display-message -p '#I' )
	cd $SCRIPT_PATH
    ./game_cross_all.sh start
	sleep 2
    ./game_cross_area.sh start
	sleep 2
    ./game.sh start
	sleep 2
	tmux selectw -t $cur_win_no
}

DOC[srv_start2]="启动游戏服务"
fun_srv_start2(){
	if tmux has -t dev:game 2> /dev/null; then
		ERR "启动失败，窗口game已存在"
		exit 1
	fi
	cd $SCRIPT_PATH
    update_tmux_win_no	
	tmux new-window -t dev:${TMUX_WIN_NO} -n game "./game.sh test"
	tmux split-window -t dev:game "./game_cross_area.sh test"
	tmux split-window -t dev:game "./game_cross_all.sh test"
	tmux select-layout -t dev:game main-vertical 
}

DOC[srv_stop]="停止游戏服务"
fun_srv_stop(){
	cd $SCRIPT_PATH
    ./game_cross_all.sh stop
    ./game_cross_area.sh stop
    ./game.sh stop
}

#DOC[srv_restart]="编译后重启游戏服务"
fun_srv_restart(){
	fun_srv_stop
	sleep 2
    INFO "正在重新编译..."
    cd ${ROOT}/server_git && make && fun_srv_start
}

DOC[srv_hotfix]="热更游戏节点"
ARG[srv_hotfix]="Minute"
fun_srv_hotfix(){
    if [ $1 ]; then
		cd $SCRIPT_PATH
    	INFO "正在热更服务器"
        ./game.sh hotfix $1
        ./game_cross_all.sh hotfix $1
        ./game_cross_area.sh hotfix $1
    fi
}

DOC[create_branch]="创建新的分支"
ARG[create_branch]="Remote Branch eg:fanti fanti_stable"
fun_create_branch(){
   remote=$1
   branch=$2

   if [ "$remote" = "" ] || [ "$branch" = "" ]; then
      error "参数有误, remote=$remote, branch=$branch"
      exit 1
   fi

   if [ -n "$(git status -s | grep -v ??)" ]; then
      echo "git仓库有修改, 先stash"
      exit 1
   fi

   # 增加分支信息   
   git config --add svn-remote.svn/$branch.url http://clsvn.ijunhai.com/svn/qz3d/server/$remote
   git config --add svn-remote.svn/$branch.fetch :refs/remotes/svn/$branch
   # 拉取数据
   git svn fetch -r HEAD svn/$branch
   git checkout -b $branch svn/$branch
}

DOC[j]="远程服务器"
ARG[j]="[Which]"
fun_j(){
   no=$1
   if [ ! $no ]; then
       INFO "1. jump-server        134.175.229.26\n"
       INFO "2. develop-machine    121. 41. 24.48\n"
       INFO "3. script-machine      47. 97.181.102\n"
       INFO "4. center-machine     121.199. 63.150\n"
       INFO "5. center-ft-machine  175. 99.  6.46\n"
       INFO "6. zll3d-release\n"
       INFO "7. zll3d-ft-release\n"
       INFO "11. 阿里云-个人\n"
       INFO "12. 搬瓦工-个人\n"
       read -p "请选择目标：" no
   fi
   case $no in
     1 | jump) 
		update_tmux_win_no
		tmux new-window -t dev:${TMUX_WIN_NO} -n Jump-Server "zssh JumpServer"
	    ;;
     2) 
		update_tmux_win_no
		tmux new-window -t dev:${TMUX_WIN_NO} -n Zll3d-Develop "zssh DevelopMachine"
	    ;;
	 3) 
		update_tmux_win_no
		tmux new-window -t dev:${TMUX_WIN_NO} -n Zll3d-Script "zssh ScriptMachine"
	    ;;
	 4) 
		update_tmux_win_no
		tmux new-window -t dev:${TMUX_WIN_NO} -n Zll3d-Center "zssh CenterMachine"
	    ;;
	 5) 
		update_tmux_win_no
		tmux new-window -t dev:${TMUX_WIN_NO} -n Zll3d-Center-Ft "zssh CenterFtMachine"
	    ;;
	 6) 
		update_tmux_win_no
		tmux new-window -t dev:${TMUX_WIN_NO} -n Zll3d-Release "zssh ScriptMachine"
		tmux split-window -t dev:Zll3d-Release "zssh CenterMachine"
		tmux select-layout -t dev:Zll3d-Release even-horizontal
		sleep 1
		tmux send-keys -t dev:Zll3d-Release.1 "cd /data/ctl/zll3d" C-m
		tmux send-keys -t dev:Zll3d-Release.2 "cd /data/ctl/" C-m
	    ;;
	 7) 
		update_tmux_win_no
		tmux new-window -t dev:${TMUX_WIN_NO} -n Zll3d-Ft-Release "zssh ScriptMachine"
		tmux split-window -t dev:Zll3d-Ft-Release "zssh CenterFtMachine"
		tmux select-layout -t dev:Zll3d-Ft-Release even-horizontal
		sleep 1
		tmux send-keys -t dev:Zll3d-Ft-Release.1 "cd /data/ctl/zll3dtw" C-m
		tmux send-keys -t dev:Zll3d-Ft-Release.2 "cd /data/ctl/" C-m
	    ;;
     11) zssh -X -i ~/.ssh/id_rsa root@120.24.193.173 ;;
     12) zssh -X -i ~/.ssh/id_rsa -p 27942 root@97.64.29.225 ;;
     *) ;;
   esac
}

jump_step_1(){
	ip=$1
	expect -c "
		set timeout 15
    	spawn -noecho zssh -X -i ~/.ssh/id_rsa -p 2222 chenzengjin@134.175.229.26; 
    	expect \"Opt\"; 
    	send $ip;
		sleep 0.5;
		send \r;
    	interact;
	" 
}

jump_tw(){
	expect -c "
		set timeout 15
    	spawn -noecho zssh -X -i ~/.ssh/id_rsa -p 1986 root@47.57.187.224; 
		expect \"]#\";
		send \"ssh 175.99.6.46 -p 1986\";
		sleep 0.5;
		send \r;
    	interact;
	" 
}

jump_step_2(){
	ip=$1
	choice=$2
	expect -c "
		set timeout 15
    	spawn -noecho zssh -X -i ~/.ssh/id_rsa -p 2222 chenzengjin@134.175.229.26; 
    	expect \"Opt\"; 
    	send $ip;
		sleep 0.5;
		send \r;
    	expect \"选择\"; 
		sleep 0.5;
    	send $choice;
		sleep 0.5;
		send \r;
    	interact;
	" 
}

jump_script(){
	ip=$1
	expect -c "
	set timeout 10
    spawn zssh -X -i ~/.ssh/id_rsa -p 2222 chenzengjin@134.175.229.26
	expect \"Opt>\" {
		send \"$ip\r\";
		interact
	}
"
}

DOC[srv_hotfix_mod]="编译热更模块代码"
fun_srv_hotfix_mod(){
    # 编译并计算时间
    start_time=$(date +%s)
    fun_srv_make_mod
    time=$(expr `date +%s` - $start_time)
    min=$(expr $time / 60 + 1)
    # 热更
    fun_srv_hotfix $min
}

DOC[srv_hotfix_all]="编译热更所有"
fun_srv_hotfix_all(){
    # 编译并计算时间
    start_time=$(date +%s)
    cd ${ROOT}/server_git && make
    time=$(expr `date +%s` - $start_time)
    min=$(expr $time / 60 + 1)
    # 热更
    fun_srv_hotfix $min
}

DOC[srv_make_mod]="编译指定模块代码"
fun_srv_make_mod(){
	path="$( find $ROOT/server_git/src -maxdepth 3 -type d | fzf --height 40% )"
    cd ${path} || exit 1
    INFO "正在编译服务器模块..."
    INFO "path:${path}"
    ebin=${ROOT}/server_git/ebin

    #params="[{i,\"${ROOT}/server_git/include\"},{outdir,\"${ROOT}/server_git/ebin\"}]"
    #erl -pa ${ebin} -noshell -eval "make:all(${params})" -s c q

    params="{['gen_server_game.erl'],[]},{i,\"${ROOT}/server_git/include\"},{outdir,\"${ROOT}/server_git/ebin\"},inline,tuple_calls,{inline_size,30},debug_info"
    erl -pa ${ebin} -noshell -eval "mmake:all(6,[${params}])" -s c q

	# todo 使用erlc并行编译
    #erlc -smp -v -I ${ROOT}/server_git/include -o ${ROOT}/server_git/ebin -pa ${ebin} *.erl

    INFO "编译源码完成"   
}

DOC[fd]="查找配置表"
ARG[fd]="[RepoVersion]"
fun_fd(){
	path="/home/jingle/data/jhgame/data/${1}/excel"
    if [ -d $path ]; then
   		find $path -name "*.xlsx" \
		| fzf --bind "enter:execute-silent(et {} &)+abort,left-click:execute-silent(et {} &)+abort" 
	else
    	echo 找不到路径:$path
    fi
}

DOC[erl_ls]="连接到erlang_ls"
fun_erl_ls(){
    name=$(epmd -names | grep erlang_ls | awk '{print $2}')
    if [ $name ]; then
        erl -sname debug -remsh $name@jingle-PC	
    else
        ERR "未找到erlang_ls服务" 
    fi
}

DOC[clean_share]="清空share共享目录"
fun_clean_share(){
	cd ~/share/ && find ./* |  grep -v "note" | xargs rm -rf
}


DOC[hot_sql]="拉取sql并执行更新"
fun_hot_sql(){
	/home/jingle/data/jhgame/hot_sql.sh		
}

# -------------- 函数调用 --------------
# 调用函数
_CALL_FUNCTION(){
    local fname="fun"
    for arg in $@; do
        fname="${fname}_${arg}"
        shift
        if is_fun_exists ${fname}; then
            ${fname} $@
            exit 0
        fi
    done
    ERR "无效的指令，请使用以下指令"
    while [ ${#DOC[@]} -ne 0 ]; do
        mink=''
        for k in ${!DOC[@]}; do
            if [ "$mink" = "" ] || [[ "$mink" > "$k" ]]; then
                mink=$k
            fi
        done
		content=${DOC[$mink]}

        >&2 echo -e -n "\e[95m${mink}\e[0;0m"
        eval "printf ' %.0s' {1..$((20 - ${#mink}))}"
        >&2 echo -ne "${content}"
        eval "printf ' %.0s' {1..$(((15 - ${#content}) * 2))}"
        >&2 echo -e "${ARG[$mink]}"

        unset DOC[$mink]
    done
}

# 根据参数调用相应命令
_CALL_FUNCTION $@
