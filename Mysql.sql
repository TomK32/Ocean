
================ 主从 ======================

select user,host from msyql.user;
create user 'dba'@'192.168.127.%' identified by 'root';
grant replication slave on *.* to dba@'192.168.127.%';

mysqldump -u root -p --single-transaction --master-data=2 --triggers --routines --all-databases > all.sql

scp all.sql lgl@192.168.127.128:/tmp

mysql -uroot -p < all.sql

change master to master_host='192.168.127.130',
master_user = 'dba',
master_password = 'root',
master_log_file = 'mysql-bin.000004',
master_log_pos = 1509;

start slave
show slave status
==============================================================

STATUS          -- 查看信息

mysql -h ip -u username -ppassword -P server_port

grant select,insert,update,delete on db_name.* to username@ '%' identified by 'password';

revoke select,insert,update,delete on db_name.* from user_name@ '%';

SHOW INDEX FROM table_name  -- 查看表上的索引

show variables like '%log_error%';    -- 错误日志
show variables like '%gene%';         -- 通用日志

show binary logs;     # 查看当前的二进制文件

set sql_log_bin=0;    # 禁止将自己的语句写入二进制记录中
set sql_log_bin=1;    # 启动二进制记录



/**

sql 注入：

  参数化查询/字符串处理/参数校验

  1 过滤输入内容，校验字符串

    php 的mysql_real_escape_string() 来剔除，或者定义自己的处理函数进行过滤，还可以使用正则表达式匹配安全的字符串。

    验证值的类型

  2 参数化查询

    mysqli 或者 pdo

    $con = new mysqli($host,$user,$pass,$db,$port,$socket);
    $query = "select * from department where dept_name=?":
    if($stmt = $con->prepare($query)){
      $stmt->bind_param("s",$depname);
      $depname = "finance";
      $stmt->execute();
      $stmt->bind_result($field1,$field2);
      while($stmt->fetch()){
        printf("%s,$s\n",$field1,$field2);
      }
      $stmt->close();
    }
    $con->close();


 */

 -- 慢查询日志

  show variables like'%query_log%';

  show variables like'%query_time%';

-- mysqldumpslow

  mysqldumpslow -t 10 /var/log/mysql/mysql-slow.log      -- 访问时间最长的10个sql
  mysqldumpslow -s c -t 10 /var/log/mysql/mysql-slow.log -- 访问次数最多的10个sql
  mysqldumpslow -s r -t 10 /var/log/mysql/mysql-slow.log -- 访问记录集最多的10个sql

-- pt-query-digest
   apt install percona-toolkit

    pt-query-digest /slow.log > slow.rtf
    pt-query-digest --since 1800s /slow.log > slow.rtf
    pt-query-digest --since '2014-04-14 22:00:00' --until '2014-04-14 23:00:00' /slow.log > slow.rtf
    pt-query-digest --limit 100% /slow.log > slow.rtf


-- 存储过程
  delimiter //
  create procedure p12 (in p1 int)
    begin
      declare v1 int;
      set v1 = p1 + 1;
      if v1 = 0 then
        insert into t(s1) values(17);
      end if;
      if p1 = 0 THEN
        update t set s1 = s1 + 1;
      ELSE
        update t set s1 = s1 + 2;
      end if;
    end; //
  delimiter ;
  call p12(0);


  delimiter //
  create procedure p13(in p1 int)
    begin
      declare v1 int;
      set v1 = p1 + 1;
      case v1
        when 0 then insert into t(s1) values(2);
        when 1 then insert into t(s1) values(3);
        else insert into t(s1) values (4);
      end case;
    end; //
  delimiter ;

  delimiter //
  create procedure p14()
   begin
    declare v int;
    set v = 0;
    while v < 5 do
      insert into t(s1) values (v);
      set v = v + 1;
    end while;
   end; //
  delimiter ;


  delimiter //
  create procedure p15()
    BEGIN
      declare v int;
      set v = 5;
      repeat
        insert into t(s1) values (v);
        set v = v + 1;
        until v >= 10
      end repeat;
    END; //
  delimiter ;


  delimiter //
  create procedure p16()
    BEGIN
      declare v int;
      set v = 10;
      loop_label: loop
        insert into t(s1) values (v);
        set v = v + 1;
        if v >= 15 THEN
          leave loop_label;
        end if;
      end loop;
    end; //
  delimiter ;


  DELIMITER //
  CREATE PROCEDURE p17(IN p1 INT,OUT p2 INT)
  LANGUAGE SQL DETERMINISTIC SQL SECURITY INVOKER
  BEGIN
    DECLARE v INT;
    start_label: LOOP
      IF v = v THEN LEAVE start_label;
      ELSE ITERATE start_label;
      END IF;
    END LOOP start_label;
    REPEAT
      WHILE 1 = 0 DO BEGIN END;
      END WHILE;
    UNTIL v = v END REPEAT;
  END; //
  DELIMITER ;

  /*
    SQL SECURITY 特征可以用来指定子程序是用创建子程序者的许可权限来执行，还是使用调用者的许可权限来执行。默认值是 DEFINER.
    SQL SECURITY DEFINER 按创建存储过程的用户的许可权限来执行
    SQL SECURITY INVOKE 按调用者的许可权限来执行
  */

  DELIMITER //
  CREATE PROCEDURE simpleproc (OUT p1 INT)
    BEGIN
      SELECT COUNT(*) INTO p1 FROM t;
    END
    //
  DELIMITER ;
  CALL simpleproc(@a);

  DELIMITER //
  CREATE PROCEDURE p1
  (IN p1 INTEGER)
  BEGIN
    DECLARE v1 CHAR(10);
    IF p1 = 1 THEN
      SET v1 = 'birds';
    ELSE
      SET v1 = 'beasts';
    END IF;
    INSERT INTO t(s1) values (v1);
  END; //


  SET sql_mode = 'ansi';
  select 'a'||'b';
  SET sql_mode = '';
  select 'a'||'b';
  show warnings;

  DELIMITER //
  SET sql_mode = 'ansi' //
  CREATE PROCEDURE pro1() select 'a'||'b' //
  SET sql_mode = '' //
  call pro1() //
  DELIMITER ;

  SHOW CREATE PROCEDURE pro1 \G;

  /*
    默认的，如果想让一个 CREATE PROCEDURE 或 CREATE FUNCTION 语句被接受，那么必须明白地指定 DETERMINISTIC,NO SQL 或 READS SQL DATA 三者中的一个，否则会产生错误

    DETERMINISTIC 确定的
    NO SQL 没有 sql 语句，当然也不会修改数据
    READS SQL DATA 只是读取数据，当然也不会修改数据
  */

-- 触发器

CREATE TABLE account(acct_num INT,amount DECIMAL(10,2));
CREATE TRIGGER ins_su BEFORE INSERT ON account
FOR EACH ROW SET @sum = @sum + NEW.amount;
SET $sum = 0;
INSERT INTO account values(1,10.00),(2,11.00),(3,12.00);
SELECT @sum;
DROP TRIGGER test.ins_sum;


-- 外键

CREATE TABLE parent(
  id INT NOT NULL,
  PRIMARY KEY(id)
  );

CREATE TABLE child(
  id INT,
  parent_id INT,
  INDEX par_ind (parent_id),
  FOREIGN KEY (parent_id) REFERENCES parent(id) ON DELETE CASCADE
  );

ALTER TABLE child DROP FOREIGN KEY fk_symbol;

/*
  要使得重新导入有外键关系的表变的更容易操作，那么mysqldump会自动在dump输出文件中包含一个语句设置FOREIGN_KEY_CHECKS为0.这就避免了dump文件在被重新装载之时，因为约束而导入失败。我们也可以手动设置这个变量
*/
SET FOREIGN_KEY_CHECKS = 0;
SOURCE dump_file_name;
SET FOREIGN_KEY_CHECKS = 1;

SELECT * FROM information_schema.KEY_COLUMN_USAGE where referenced_table_schema is not null;

-- 视图

CREATE VIEW test.v AS SELECT * FROM t;
SELECT * FROM test.v;

CREATE TEMPORARY TABLE tmp_a AS SELECT * FROM t;
SELECT * FROM tmp_a;

/*
  这里 explain 的select_type 输出显示 derived（查询结果来自一个衍生表），那么查询使用的是临时表的方式，使用临时表的方式，性能可能会变得很差，也就是说，视图里应尽量避免使用 group by 等；
*/
CREATE VIEW test.v AS SELECT * FROM t GROUP BY name;
EXPLAIN SELECT * FROM test.v;


-- 5.1 存储树形结构

CREATE TABLE comments(
  comment_id int(10) NOT NULL AUTO_INCREMENT,
  parent_id int(10) DEFAULT NULL,
  comment text NOT NULL,
  PRIMARY KEY (comment_id)
)ENGINE=InooDB DEFAULT CHARSET=utf8;

INSERT INTO comments(parent_id,comment) values(0,'这本书不错');
INSERT INTO comments(parent_id,comment) values(1,'此书作者和译者的视野颇为广阔；在思想上更大胆');
INSERT INTO comments(parent_id,comment) values(1,'我在犹豫要不要买');
INSERT INTO comments(parent_id,comment) values(2,'说的有道理');
INSERT INTO comments(parent_id,comment) values(3,'值得购买，内容比较契合目前的数据发展潮流');
INSERT INTO comments(parent_id,comment) values(5,'封面和纸张设计，做工感觉有点粗糙了');
INSERT INTO comments(parent_id,comment) values(0,'在当下这个大数据时代，这本书一定要看');
INSERT INTO comments(parent_id,comment) values(3,'该书气味之大，装帧之差实属罕见');
INSERT INTO comments(parent_id,comment) values(7,'这本书必须要看');
INSERT INTO comments(parent_id,comment) values(7,'比较实用，实践性比较强');

/*
  如果采用这样的结构，当一篇帖子回复讨论的内容很多的时候，就需要编写负责的代码递归检索很多记录，查询的效率就会很低。如果数据量不大，讨论内容相对固定，数据的层次较少，那么采用这样的结构就会是简单的/清晰的，这种情况下此结构还是合适的；但如果数据量很大，查询就会变的很复杂。两种更通用，扩展更好的解决方案： 路径枚举 和 闭包表
*/

-- 5.1.1 路径枚举

/* 对于上面的表结构，可以增加一个字段path，用于记录节点的所有祖先信息。记录的方式是把所有的祖先信息组织成一个字符串*/

comment_id    parent_id   path    comment
1             0           1/
2             1           1/2
3             1           1/3
4             2           1/2/4
5             3           1/3/5
6             5           1/3/5/6
7             0           7/
8             3           1/3/8
9             7           7/9
10            7           7/10

UPDATE comments set path="1/" where comment_id=1;
UPDATE comments set path="1/2" where comment_id=2;
UPDATE comments set path="1/3" where comment_id=3;
UPDATE comments set path="1/2/4" where comment_id=4;
UPDATE comments set path="1/3/5" where comment_id=5;
UPDATE comments set path="1/3/5/6" where comment_id=6;
UPDATE comments set path="7/" where comment_id=7;
UPDATE comments set path="1/3/8" where comment_id=8;
UPDATE comments set path="7/9" where comment_id=9;
UPDATE comments set path="7/10" where comment_id=10;

-- 查找 comment_id 等于 3 的所有后代
select * from comments where path like '1/3/_%';

-- 查找下一层子节点
select * from comments where path regexp "^1/3/[0-9]+$";


-- 5.1.2 闭包表
  /*
    闭包表也是一种通用的解决方案，它需要额外增加一张表，用于记录节点之间的关系。它不仅记录了节点之间的父子关系，也记录了所有节点之间的关系。

    ancestor 表示祖先，descendant 表示后代，存储的是comment_id的值

    为了更方便的查询直接父节点/子节点，可以增加一个 path_length 字段表示深度，节点的自我引用path_length等于0，到它的直接子节点的 path_length 等于1 ，再下一层为2，以此类推
  */

  CREATE TABLE path(
    ancestor int(11) NOT NULL,
    descendant int(11) NOT NULL,
    PRIMARY KEY (ancestro,descendant)
  )ENGINE=InnoDB DEFAULT CHARSET=utf8;

  -- 统计 comment_id 等于 3 的所有后代（不包括其自身）
  select count(*) from path where ancestro=3 and descendant<>3;




-- 5.2 转换字符集
/*
修改a表的字符集为 utf8，假如原来为 gbk
*/

  show create table ;  -- 查看表的编码
  insert into b select * from a;  --建立一个临时表b，数据类型和a一致
  drop table a;
  rename table b to a;


  mysqldump -t -uroot -p test --tables test --default-character-set=gbk > test_gbk.sql
  iconv -fgbk -tutf-8 test_gbk.sql > a_utf.sql
  sed -i 's/SET NAMES gbk/SET NAMES utf8/' a_utf8.sql
  mysql -uroot -p test --default-character-set=utf8 < test_utf8.sql


  mysqldump --default-character-set=latin1 -u root -p test table_name > table_name.sql
  vim table_name.sql
  /*! 40101 SET NAMES latin1 */     改为   /*! 40101 SET NAMES gbk */
  DEFAULT CHARSET = latin1;         改为   DEFAULT CHARSET=gbk
  mysql -uroot -p test < table_name.sql;


-- 5.3 处理重复值
  CREATE TABLE person1(
    first_name CHAR(20),
    last_name CHAR(20),
    sex CHAR(10)
  );

  CREATE TABLE person2(
    first_name CHAR(20),
    last_name CHAR(20),
    sex CHAR(10),
    PRIMARY KEY (last_name,first_name)
  );

  CREATE TABLE person3(
    first_name CHAR(20),
    last_name CHAR(20),
    sex CHAR(10),
    UNIQUE (last_name,first_name)
  );

  INSERT IGNORE INTO person1(last_name,first_name) values('liu','guilong');
  INSERT IGNORE INTO person1(last_name,first_name) values('liu','guilong');

  REPLACE INTO pserson2(last_name,first_name) values('liu','guilong');
  REPLACE INTO pserson2(last_name,first_name) values('liu','guilong');
  REPLACE INTO pserson2(last_name,first_name) values('liu','guilong1');

  SELECT COUNT(*) as r,last_name,first_name FROM person1 GROUP BY last_name,first_name HAVING r > 1;
  SELECT DISTINCT last_name,first_name FROM pserson1 ORDER BY last_name;
  SELECT last_name,first_name FROM person1 GROUP BY last_name,first_name;

  CREATE TABLE tmp SELECT last_name,first_name,sex FROM person1 GROUP BY last_name,first_name;
  DROP TABLE person1;
  ALTER TABLE tmp RENAME TO person1;

  DELETE t1 FROM person1 as t1 JOIN person1 as t2 ON t1.id > t2.id AND t1.last_name = t2.last_name AND t1.first_name = t2.first_name;

-- 多表 UPDATE
  UPDATE product p,product_price pp SET pp.price = p.price * 0.8 WHERE p.id = pp.pid;
  UPDATE product p INNER JOIN product_price pp ON p.id = pp.pid SET pp.price = p.price * 0.7;

  UPDATE product p
  LEFT JOIN product_price pp
  ON p.id = pp.pid
  SET p.deleted = 1
  WHERE pp.pid IS NULL


-- 查询优化
  /*
    1 优化数据访问
      尽量减少对数据的访问。一般有如下两个需要考虑的地方：应用程序应
  */

  -- 使用索引
  SELECT * FROM table USER INDEX(index_col1,index_col2) WHERE col1 = 1 AND ool2 = 2 AND col3 = 3;

  -- 不使用索引
  SELECT * FROM table IGNORE INDEX (index_col3) WHERE col1 = 1 AND ool2 = 2 AND col3 = 3;

  -- 强制只用索引 FORCE INDEX

  -- 不使用查询缓冲 SQL_NO_CACHE

  -- 使用查询缓冲 SQL_CACHE


-- my.cnf
[client]
port = 3306
socket = /tmp/mysql.sock
default-character-set = utf8

[mysqld]
character-set-server = utf8
port = 3306
socket = /tmp/mysql.sock
user = mysql
skip-external-locking
max_connections = 3000
max_connect_errors = 3000
thread_cache_size = 300
skip-name-resolve
server-id = 1
binlog_format = mixed
expire-logs-days = 8
sync_binlog = 60
innodb_log_file_size = 256M
default-storage-engine=innodb

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash
# Remove the next comment character if you are not familiar whith SQL
# safe-updates
default-character-set = utf8


-- 性能测试

apt install sysbench

sysbench --test=cpu --cpu-max-prime=20000 run  # sysbench 命令通过进行素数运算来测试cpu性能。cpu-max-prime 指定了最大的素数为20000
sysbench --test=cpu --cpu-max-prime=20000 run --max-time=20

sysbench --test=threads --num-threads=64 --thread-yields=1000 --thread-locks=8 run    #   线程测试


sysbench --test=memory --memory-block-size=8K --memory-total-size=4G run  # 在内存中传输4GB的数据量，每个块（block）大大小为8KB

-- I/O测试

innodb_flush_log_at_trx = 1  -- 每次 commit 时都写入磁盘。这样理论上只会丢失一个事务
innodb_flush_log_at_trx = 2  -- 每次 commit 时，写日志只缓冲（buffer）到操作系统缓存，但不刷新到磁盘，innodb会每秒刷新一次日志，所以宕机丢失的是最                                近1秒的事务。生产环境中建议使用此配置
innodb_flush_log_at_trx = 3  -- 每秒把日志缓冲区的内容写到日志文件，并且刷新到磁盘，但 commit 什么也不做


show session status like 'Select%';



CHANGE MASTER TO
MASTER_HOST='192.168.127.130',
MASTER_PORT=3306,
MASTER_USER='root',
MASTER_PASSWORD='root',
MASTER_LOG_FILE='mysql-bin.000003',
MASTER_LOG_POS= 706;


change master to master_host='192.168.127.130',master_user='repl',master_password='root',master_log_file='mysql-bin.000004',master_log_pos=154;








































































