### 魔改 erlang_ls 插件
* erlang版本:24
* 下载erlang_ls源码（tag: 0.36.0），修改 els_config.erl，初始化 apps_paths 过程改为递归展开。
``` erlang
index 7412070..b083e92 100644
--- a/apps/els_core/src/els_config.erl
+++ b/apps/els_core/src/els_config.erl
@@ -187,7 +187,7 @@ do_initialize(RootUri, Capabilities, InitOptions, {ConfigPath, Config}) ->
         )
     ),
     %% Calculated from the above
-    ok = set(apps_paths, project_paths(RootPath, AppsDirs, false)),
+    ok = set(apps_paths, project_paths(RootPath, AppsDirs, true)),
     ok = set(deps_paths, project_paths(RootPath, DepsDirs, false)),
     ok = set(include_paths, include_paths(RootPath, IncludeDirs, false)),
     ok = set(otp_paths, otp_paths(OtpPath, false) -- ExcludePaths),
@@ -198,7 +198,7 @@ do_initialize(RootUri, Capabilities, InitOptions, {ConfigPath, Config}) ->
         search_paths,
         lists:append([
             project_paths(RootPath, AppsDirs, true),
-            project_paths(RootPath, DepsDirs, true),
+            project_paths(RootPath, DepsDirs, false),
             include_paths(RootPath, IncludeDirs, false),
             otp_paths(OtpPath, true)
         ])
@@ -339,11 +339,7 @@ include_paths(RootPath, IncludeDirs, Recursive) ->
 project_paths(RootPath, Dirs, Recursive) ->
     Paths = [
         els_utils:resolve_paths(
-            [
-                [RootPath, Dir, "src"],
-                [RootPath, Dir, "test"],
-                [RootPath, Dir, "include"]
-            ],
+            [ [RootPath, Dir] ],
             RootPath,
             Recursive
         )
```
* make 编译，生成 _build 文件夹，里面有魔改生成的bin文件
* vscode 中安装 erlang_ls 插件，配置 dapPath 和 serverPath 指向 _build 文件夹中对应的bin文件即可
