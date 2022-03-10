### 魔改 erlang_ls 插件
* 下载erlang_ls源码，修改 els_config.erl，初始化 apps_paths 过程改为递归展开。
``` erlang
diff --git a/apps/els_core/src/els_config.erl b/apps/els_core/src/els_config.erl
index 2fd3652..d4e23a1 100644
--- a/apps/els_core/src/els_config.erl
+++ b/apps/els_core/src/els_config.erl
@@ -148,7 +148,7 @@ do_initialize(RootUri, Capabilities, InitOptions, {ConfigPath, Config}) ->
   ok = set(compiler_telemetry_enabled, CompilerTelemetryEnabled),
   ok = set(incremental_sync, IncrementalSync),
   %% Calculated from the above
-  ok = set(apps_paths     , project_paths(RootPath, AppsDirs, false)),
+  ok = set(apps_paths     , project_paths(RootPath, AppsDirs, true)),
   ok = set(deps_paths     , project_paths(RootPath, DepsDirs, false)),
   ok = set(include_paths  , include_paths(RootPath, IncludeDirs, false)),
   ok = set(otp_paths      , otp_paths(OtpPath, false) -- ExcludePaths),
@@ -157,7 +157,7 @@ do_initialize(RootUri, Capabilities, InitOptions, {ConfigPath, Config}) ->
   %% All (including subdirs) paths used to search files with file:path_open/3
   ok = set( search_paths
           , lists:append([ project_paths(RootPath, AppsDirs, true)
-                         , project_paths(RootPath, DepsDirs, true)
+                         , project_paths(RootPath, DepsDirs, false)
                          , include_paths(RootPath, IncludeDirs, false)
                          , otp_paths(OtpPath, true)
                          ])
@@ -274,10 +274,7 @@ include_paths(RootPath, IncludeDirs, Recursive) ->

 -spec project_paths(path(), [string()], boolean()) -> [string()].
 project_paths(RootPath, Dirs, Recursive) ->
-  Paths = [ els_utils:resolve_paths( [ [RootPath, Dir, "src"]
-                                     , [RootPath, Dir, "test"]
-                                     , [RootPath, Dir, "include"]
-                                     ]
+  Paths = [ els_utils:resolve_paths( [ [RootPath, Dir] ]
                                    , RootPath
                                    , Recursive
                                    )
diff --git a/apps/els_lsp/src/els_indexing.erl b/apps/els_lsp/src/els_indexing.erl
index 0b3ece7..91998ce 100644
--- a/apps/els_lsp/src/els_indexing.erl
+++ b/apps/els_lsp/src/els_indexing.erl
```
* make 编译，生成 _build 文件夹，里面有魔改生成的bin文件
* vscode 中安装 erlang_ls 插件，配置 dapPath 和 serverPath 指向 _build 文件夹中对应的bin文件即可
