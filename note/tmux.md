## tmux

### session

```bash
创  建          tmux new -s <session-name>
进  入				 	tmux attach -t  <session-name>
命  名 			    ctrl + x $
切  换		      ctrl + x ( or )
离  开          ctrl + x d
列  表          ctrl + x s
关  闭				  ctrl + d
```


### window
```bash
创  建          ctrl + x c
列  表          ctrl + x w
切  换          ctrl + x n or p
命  名          ctrl + x ,
关  闭          ctrl + x &
窗口移动         ctrl+x :join-pane -t $window_name 	# 将当前窗口附加到指定窗口中

```

```html
 窗口标识符
 Symbol    Meaning
  *        Denotes the current window.
  -        Marks the last window (previously selected).
  #        Window activity is monitored and activity has been detected.
  !        Window bells are monitored and a bell has occurred in the window.
  ~        The window has been silent for the monitor-silence interval. 
  M        The window contains the marked pane.
  Z        The window's active pane is zoomed.
```



### panel
```bash
左右切割       ctrl + x %
上下切割       ctrl + x “
移   动       ctrl + x 方向键
关   闭       ctrl + x x
放大/还原      ctrl + x z
显示时间       ctrl + x t
调整大小       ctrl + x alt+方向键
分离窗口       ctrl + x :break-pane -n $pane_name   # 对应 join-pane
切换方向       ctrl + x space                       # 多个panel横竖排列切换
切换顺序       ctrl + x ctrl+o                      # 多个panel显示顺序切换
```

### 其他
1. **复制**，按住shift再进行选择
2. **搜索**，prefix+[ 进入滚屏模式，再按 ctrl+s 进行搜索，n和N进行选择
3. 

