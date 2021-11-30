## screen

### 使用

```bash
创   建          screen -S <session-name>
进   入				 	 screen -r  <session-name>
强制进入			 	  screen -D -r  <session-name>
共享进入				 	screen -x -r  <session-name>
离   开          ctrl-a d
滚   屏          Ctrl-a [
关   闭				   ctrl + d
```

### 常用screen参数

```bash
C-a ? -> Help，显示简单说明
C-a c -> Create，开启新的 window
C-a n -> Next，切换到下个 window 
C-a p -> Previous，前一个 window 
C-a 0..9-> 切换到第 0..9 个window
Ctrl+a [Space] -> 由視窗0循序換到視窗9
C-a C-a -> 在两个最近使用的 window 间切换 
C-a x -> 锁住当前的 window，需用用户密码解锁
C-a d -> detach，暂时离开当前session
C-a z -> 把当前session放到后台执行，用 shell 的 fg 命令則可回去
C-a w -> Windows，列出已开启的 windows 有那些 
C-a t -> Time，显示当前时间，和系统的 load 
C-a K -> kill window，强行关闭当前的 window
C-a [ -> 进入 copy mode，在 copy mode 下可以回滚、搜索、复制就像用使用 vi 一样
    C-b Backward，PageUp 
    C-f Forward，PageDown 
    H(大写) High，将光标移至左上角 
    L Low，将光标移至左下角 
    0 移到行首 
    $ 行末 
    w forward one word，以字为单位往前移 
    b backward one word，以字为单位往后移 
    Space 第一次按为标记区起点，第二次按为终点 
    Esc 结束 copy mode 

C-a ] -> Paste，把刚刚在 copy mode 选定的内容贴上
```

