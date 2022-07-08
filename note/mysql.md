## mysql

### 执行 sql 脚本
```bash
mysql -ugame -p$(cat /data/mysql) -f fanti_dev < hot.sql
```

### 数据库结构导出
```bash
mysqldump -ugame -p$(cat /data/mysql ) -d fanti > fanti.sql
```

### 修改 text 字段为 not null

```mysql
-- 先将数据库中的NULL字段修改，再进行modify
update player_shys set puzzle_list = '[]' where puzzle_list is NULL;
alter table player_shys modify column puzzle_list text not null;
```