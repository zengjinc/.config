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
declare -A DOC 
declare -A ARG

ROOT=$(get_real_path)

SRV_PATH=$ROOT/server_git
SCRIPT_PATH=$ROOT/script
DATA_PATH=$ROOT/data
PROTO_PATH=$ROOT/proto
WEB_PATH=$ROOT/web
SQL_PATH=$ROOT/sqls
EBIN_PATH=$ROOT/ebin

# erl 21 版本
ERL=/usr/local/lib/erlang/bin/erl

# tmux session name
T_NAME=dev

# 主开发版本
DEV_VER=fanli_dev
DEV_PROTO_VER=fanli



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
    echo -e "\e[92m=>\e[0m ${1}"
}

# 输出一条错误信息
ERR(){
    >&2 echo -e "\e[91m>>\e[0m ${1}"
}

# 输出绿色信息
MSG(){
    echo -e "\e[92m${1}\e[0m"
}

# 输出红色信息
ERR_MSG(){
    echo -e "\e[91m${1}\e[0m"
}


# 检查锁
lock_check(){
    local task=$1
    local msg=$2
    lock=/tmp/running_xc2_${task}.lock
    if [ -f $lock ]; then
        taskname=$(<$lock)
        ERR "正在执行\"$taskname\"任务，需等待该任务完成..."
        exit 1
    fi
    touch $lock # 加锁
    echo $msg > $lock
}

# 解锁
lock_release(){
    local task=$1
    lock=/tmp/running_xc2_${task}.lock
    rm -f $lock
}

# 输出命令行补全信息
fun_completion(){
    echo $(declare -p DOC)
}

# 获取tmux新建窗口no
get_tmux_win_no(){
    expr $(tmux list-window -t ${T_NAME} 2>&1 | wc -l) + 1
}

current_branch(){
	git branch 2>&1 | grep "*" | awk '{print $2}'	
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
                    fun_pull_all
                    git stash pop -q
                else
                    fun_pull_all
            fi
        elif [ -d $v/.svn ]; then
            echo ---------------------------------------------
            INFO "更新仓库: \e[92m$(basename $v)\e[0;0m 使用策略tf"
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
            INFO "更新仓库: \e[92m$(basename $v)\e[0;0m 使用策略tf"
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
DOC[pull_all]="更新所有分支"
fun_pull_all(){
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
    if [ -e "${DATA_PATH}/${1}/run.sh" ]; then
		path="${DATA_PATH}/${1}"
	else
		# 默认
		path="${DATA_PATH}/${DEV_VER}"
    fi
	INFO "version:${path}"
    cd ${path} && ./run.sh $@ #&& rm -rf tabletool/Logs/LogExcelHead
}

DOC[gen_proto]="调用生成协议脚本"
ARG[gen_proto]="[RepoVersion]"
fun_gen_proto(){
	if [ -e "${PROTO_PATH}/${1}/run.sh" ]; then
		path="${PROTO_PATH}/${1}"
	else
		# 默认
		path="${PROTO_PATH}/${DEV_PROTO_VER}"
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
    W_NAME=game
	if tmux has -t $T_NAME:$W_NAME 2> /dev/null; then
		ERR "启动失败，窗口game已存在"
		exit 1
	fi
	cd $SCRIPT_PATH
	tmux new-window -t $T_NAME:$(get_tmux_win_no) -n $W_NAME "./game.sh test"
	tmux split-window -t $T_NAME:$W_NAME "./game_cross_area.sh test"
	tmux split-window -t $T_NAME:$W_NAME "./game_cross_all.sh test"
	tmux select-layout -t $T_NAME:$W_NAME main-vertical 
}

DOC[srv_stop]="停止游戏服务"
fun_srv_stop(){
	cd $SCRIPT_PATH
    ./game_cross_all.sh stop
    ./game_cross_area.sh stop
    ./game.sh stop
}

DOC[srv_restart]="编译后重启游戏服务"
fun_srv_restart(){
	fun_srv_stop
	sleep 2
    INFO "正在重新编译..."
    cd ${SRV_PATH} && fun_make && fun_srv_start
}

DOC[srv_hotfix]="热更游戏节点"
ARG[srv_hotfix]="Minute"
fun_srv_hotfix(){
    if [ $1 ]; then
		cd $SCRIPT_PATH
    	INFO "正在热更服务器"
        ./game.sh hotfix $1
        ./game.sh reboot_wn "hotfix_finish" > /dev/null
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
      ERR "参数有误, remote=$remote, branch=$branch"
      exit 1
   fi

   if [ -n "$(git status -s | grep -v ??)" ]; then
      ERR "git仓库有修改, 先stash"
      exit 1
   fi

	read -e -p $(echo -e "从http://clsvn.ijunhai.com/svn/qz3d/server/\e[92m$remote\e[0m拉取创建分支\e[92m$branch\e[0m?(y/n):") choice

	if [ $choice == "y" ]; then
   		# 增加分支信息   
   		git config --add svn-remote.svn/$branch.url http://clsvn.ijunhai.com/svn/qz3d/server/$remote
   		git config --add svn-remote.svn/$branch.fetch :refs/remotes/svn/$branch
   		# 拉取数据
   		git svn fetch -r HEAD svn/$branch
   		git checkout -b $branch svn/$branch
   fi
}

DOC[merge_branch]="合并分支代码"
ARG[merge_branch]="Destination Sorce eg:fanti fanti_dev"
fun_merge_branch(){
    dest=$1
    src=$2

    if [ -z $(git branch --list $dest) ] || [ -z $(git branch --list $src) ]; then
       ERR "分支有误, dest=$dest, src=$src"
       exit 1
    fi

    if [ -n "$(git status -s | grep -v ??)" ]; then
       ERR "仓库有修改, 先stash"
       exit 1
    fi

	read -e -p $(echo -e "从\e[92m$src\e[0m分支合并src、include到\e[92m$dest\e[0m?(y/n):") choice

	if [ $choice == "y" ]; then

        git checkout $src && git up \
        && git checkout $dest && git up \
        && git checkout --theirs --progress $src -- src/ \
        && git checkout --theirs --progress $src -- include/ \

        if [ $? -eq 0 ]; then
            INFO "合并完成"
        else
            ERR "合并过程出错..."
            exit 1
        fi

	 fi
}

DOC[export_svn]="版本合并同步"
ARG[export_svn]="Destination Sorce eg:fanti_dev fanli_dev"
fun_export_svn(){

    dest_data=$DATA_PATH/$1/excel/
    src_data=$DATA_PATH/$2/excel/

	dest_web=$WEB_PATH/$1/app/modules/
	src_web=$WEB_PATH/$2/app/modules/
	
	if [ ! $1 ] || [ ! $2 ]; then
		ERR "传入参数有误"
		exit 1
	fi

	if [ ! -d $desc_data ] || [ ! -d $src_data ] || [ ! -d $dest_web ] || [ ! -d $src_web ]; then
		ERR  "目录有误"
	    ERR_MSG "dest_data=$dest_data"	
	    ERR_MSG "src_data=$src_data"	
	    ERR_MSG "dest_web=$dest_web"	
	    ERR_MSG "src_web=$src_web"	
		exit 1
	fi

	read -e -p $(echo -e "从\e[92m$2\e[0m合并excel到\e[92m$1\e[0m?(y/n):") choice_excel

	if [ $choice_excel == "y" ]; then
		svn export --force --quiet $src_data $dest_data 	
		INFO "=====导出DATA完成====="
		svn st $dest_data
		cd $dest_data
		svn add --force .
		/home/jingle/.svn_commit_check.sh ci -m "版本同步"
		
	fi

	read -e -p $(echo -e "从\e[92m$2\e[0m合并web到\e[92m$1\e[0m?(y/n):") choice_web

	if [ $choice_web == "y" ]; then
		svn export --force --quiet $src_web $dest_web
		INFO "=====导出WEB完成====="
		svn st $dest_web
		cd $dest_web
		svn add --force .
		/home/jingle/.svn_commit_check.sh ci -m "版本同步"
		
	fi
}

DOC[export_proto]="协议合并同步"
ARG[export_proto]="Destination Sorce eg:fanti fanli"
fun_export_proto(){

	dest_proto=$PROTO_PATH/$1/proto/
    src_proto=$PROTO_PATH/$2/proto/
	
	if [ ! $1 ] || [ ! $2 ]; then
		ERR "传入参数有误"
		exit 1
	fi

	if [ ! -d $dest_proto ] || [ ! -d $src_proto ]; then
		ERR  "目录有误"
	    ERR_MSG "dest_proto=$dest_proto"	
	    ERR_MSG "src_proto=$src_proto"	
		exit 1
	fi

	read -e -p $(echo -e "从\e[92m$2\e[0m合并proto到\e[92m$1\e[0m?(y/n):") choice_proto

	if [ $choice_proto == "y" ]; then
		svn export --force --quiet $src_proto $dest_proto 	
		INFO "=====导出PROTO完成====="
		svn st $dest_proto
		cd $dest_proto
		svn add --force .
		/home/jingle/.svn_commit_check.sh ci -m "版本同步"
		
	fi

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
		tmux new-window -t $T_NAME:$(get_tmux_win_no) -n Jump-Server "zssh JumpServer"
	    ;;
     2 | dev) 
		tmux new-window -t $T_NAME:$(get_tmux_win_no) -n Zll3d-Develop "zssh DevelopMachine"
	    ;;
	 3 | scr) 
		tmux new-window -t $T_NAME:$(get_tmux_win_no) -n Zll3d-Script "zssh ScriptMachine"
	    ;;
	 4 | center) 
		tmux new-window -t $T_NAME:$(get_tmux_win_no) -n Zll3d-Center "zssh CenterMachine"
	    ;;
	 5 | center-ft) 
		tmux new-window -t $T_NAME:$(get_tmux_win_no) -n Zll3d-Center-Ft "zssh CenterFtMachine"
	    ;;
	 6) 
		tmux new-window -t $T_NAME:$(get_tmux_win_no) -n Zll3d-Release "zssh ScriptMachine"
		tmux split-window -t $T_NAME:Zll3d-Release "zssh CenterMachine"
		tmux select-layout -t $T_NAME:Zll3d-Release even-horizontal
		sleep 1
		tmux send-keys -t $T_NAME:Zll3d-Release.1 "cd /data/ctl/zll3d" C-m
		tmux send-keys -t $T_NAME:Zll3d-Release.2 "cd /data/ctl/" C-m
	    ;;
	 7) 
		tmux new-window -t $T_NAME:$(get_tmux_win_no) -n Zll3d-Ft-Release "zssh ScriptMachine"
		tmux split-window -t $T_NAME:Zll3d-Ft-Release "zssh CenterFtMachine"
		tmux select-layout -t $T_NAME:Zll3d-Ft-Release even-horizontal
		sleep 1
		tmux send-keys -t $T_NAME:Zll3d-Ft-Release.1 "cd /data/ctl/zll3dtw" C-m
		tmux send-keys -t $T_NAME:Zll3d-Ft-Release.2 "cd /data/ctl/" C-m
	    ;;
     11) zssh -X -i ~/.ssh/id_rsa root@120.24.193.173 ;;
     12) zssh -X -i ~/.ssh/id_rsa -p 27942 root@97.64.29.225 ;;
     *) ;;
   esac
}

jump_script(){
	ip=$1
	expect -c "
	set timeout 10
    spawn zssh JumpServer
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
    cd $SCRIPT_PATH && ./game.sh reboot_wn "recompile_some_code..." > /dev/null
    fun_srv_make_mod $1
    time=$(expr `date +%s` - $start_time)
    min=$(expr $time / 60 + 1)
    # 热更
    fun_srv_hotfix $min
}

DOC[srv_hotfix_all]="编译热更所有"
fun_srv_hotfix_all(){
    # 编译并计算时间
    start_time=$(date +%s)
    cd $SCRIPT_PATH && ./game.sh reboot_wn "recompile_all_code..." > /dev/null
    fun_make
    time=$(expr `date +%s` - $start_time)
    min=$(expr $time / 60 + 1)
    # 热更
    fun_srv_hotfix $min
}

DOC[make]="编译所有代码"
fun_make(){
    cd ${SRV_PATH}

	process_num=12
    # 需要debug信息时增加
    params="debug_info"
    # params=""

	make ERL=$ERL PROCESS_NUM=$process_num MAKE_OPTS=$params

    rsync_path=${EBIN_PATH}/$(current_branch)/
    mkdir -p ${rsync_path}
	rsync -rt --delete ebin/ ${rsync_path}
}

DOC[srv_make_mod]="编译指定模块代码"
fun_srv_make_mod(){
    if [ $1 ]; then
        path=$1
    else
	    path="$( find $SRV_PATH/src -maxdepth 3 -type d | fzf --height 40% )"
    fi
    cd ${path} || exit 1
    INFO "正在编译服务器模块..."
    INFO "path:${path}"

    ebin=${SRV_PATH}/ebin
	include=${SRV_PATH}/include
	outdir=${SRV_PATH}/ebin
    # 需要debug信息时增加
    params="{['gen_server_game.erl'],[]},{i,\"${include}\"},{outdir,\"${outdir}\"},inline,tuple_calls,{inline_size,30},debug_info"
    # params="{['gen_server_game.erl'],[]},{i,\"${include}\"},{outdir,\"${outdir}\"},inline,tuple_calls,{inline_size,30}"

    $ERL -pa ${ebin} -noshell -eval "mmake:all(12,[${params}])" -s c q

    rsync_path=${EBIN_PATH}/$(current_branch)/
    mkdir -p ${rsync_path}
	rsync -rtv --delete $ebin/ ${rsync_path}

    INFO "编译源码完成"   
}

DOC[fd]="查找配置表"
ARG[fd]="[RepoVersion]"
fun_fd(){
	path="${DATA_PATH}/${1}/excel"
    if [ -d $path ]; then
   		find $path -name "*.xlsx" \
		| fzf --bind "enter:execute-silent(et {} &)+abort,left-click:execute-silent(et {} &)+abort" 
	else
    	echo 找不到路径:$path
    fi
}

DOC[erl_ls]="连接到erlang_ls"
fun_erl_ls(){
	if [ $1 ]; then
		name=$1	
	else
    	name=$(epmd -names | grep erlang_ls | awk '{print $2}' | head -n 1)
	fi
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

DOC[hotsql]="拉取sql并执行更新"
fun_hotsql(){
	# 设定为定时任务 每小时执行一次
	dev_sqls="${SQL_PATH}/${DEV_VER}/*.sql"
	fanti_sqls="${SQL_PATH}/fanti_dev/*.sql"
	log_file="${ROOT}/hot_log.txt"
	time_file="${ROOT}/hot_time.txt"

	if [ -f $time_file ]; then
		last_t=$(cat $time_file)
	else
		last_t=0
	fi	
	
	# 更新
	if [ $(date +%u) -eq 1 ] && [ $(date +%H) -eq 10 ]; then
	    # 每周清空
		echo "==== hot sqls : $(date '+%y-%m-%d %T') ====" > $log_file
		svn up $SQL_PATH >> $log_file
	else
		echo "==== hot sqls : $(date '+%y-%m-%d %T') ====" >> $log_file
		svn up $SQL_PATH >> $log_file
	fi

	now_t=$(date +%s)
	
	# dev
	INFO "hot ${DEV_VER}" >> $log_file
	for file in $dev_sqls
	do
	    change_t=$(stat -c %Z $file)
	    if [ $change_t -gt $last_t ] && [ $change_t -le $now_t ] && [ $(head -n 1 $file | awk '{print $2}') != "陈增锦" ]; then
	          MSG "execute $(basename $file)" >> $log_file
	          mysql -uroot -p123456 fanli_local -f < $file >> $log_file 2>&1
	    fi
	done

	# fanti
	INFO "hot fanti_dev" >> $log_file
	for file in $fanti_sqls
	do
	    change_t=$(stat -c %Z $file)
	    if [ $change_t -gt $last_t ] && [ $change_t -le $now_t ] && [ $(head -n 1 $file | awk '{print $2}') != "陈增锦" ]; then
	          MSG "execute $(basename $file)" >> $log_file
	          mysql -uroot -p123456 fanti_local -f < $file >> $log_file 2>&1
	    fi
	done
	
	# 更新时间
	echo $now_t > $time_file
	echo -e "done.\n" >> $log_file
}

DOC[test]="测试方法"
fun_test(){
    echo $ROOT
	echo $(get_tmux_win_no)
    
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
