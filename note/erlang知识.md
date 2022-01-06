### 中文编码转换
``` erlang
%% 8位
erlang:list_to_bianry().
%% 16位
erlang:list_to_binary(unicode:characters_to_list(X)).
```

### remsh方式连接erlang节点
```erlang
erlang -sname debug -remsh erlang_ls_projectname_628803@`HOSTNAME`
```