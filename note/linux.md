### 开机启动脚本
* 在路径 ==~/.config/autostart== 中新建 .desktop 文件
* 添加到  /etc/rc.local 脚本中

### 更改分辨率1
```bash
cvt 1920 1980 60
xrandr --newmode "1920x1080_60.00" 173.00 1920 2048 2248 2576 1080 1083 1088 1120 -hsync +vsync
xrandr --addmode Virtual1 "1920x1080_60.00"
xrandr --output Virtual1 --mode "1920x1080_60.00"
```

### 创建桌面图标
```bash
sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database
```

### fzf
模糊查找 | fzf选择打开并终止fzf

```bash
find ~/data/jhgame/data/fanli_dev/excel/ -name "*.xlsx" | fzf --bind "enter:execute-silent(et {} &)+abort"
```

搜索语法

| Token  | Match Type           | Description  |
| ------ | -------------------- | ------------ |
| sbtrkt | fuzzy-match          | 匹配sbtrkt   |
| ^music | prefix-exact-match   | 以music开头  |
| !file  | inverse-suffix-match | 不包含file   |
| 'wild  | exact-match(quoted)  | 精确包含wild |
| .mp3$  | suffix-exact-match   | 以.mp3结尾   |
| !.mp3$ | inverse-suffix-match | 不为.mp3结尾 |


### powerline 自定义配置

> 参考链接: 
> https://note.qidong.name/2020/09/customize-powerline/

### 统计目录空间
```bash
sudo du -sh /home/jingle
```


### 在运行命令时设置环境变量
```bash
PREFIX=/path/to/directory make -e install
```

