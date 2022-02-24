### 魔改 erlang_ls 插件
* 下载erlang_ls源码，修改 els_config.erl，初始化 apps_paths 过程改为递归展开。
``` erlang
ok = set(apps_paths, project_paths(RootPath, AppsDirs, true)), % false -> true
```
* make 编译，生成 _build 文件夹，里面有魔改生成的bin文件
* vscode 中安装 erlang_ls 插件，进入插件安装目录并替换对应的bin文件即可 
	~/.vscode/extensions/erlang-ls.erlang-ls-0.0.32/erlang_ls/_build
