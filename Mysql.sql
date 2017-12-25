
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


============================== 导入官方示例库 ========================================

wget https://launchpad.net/test-db/employees-db-1/1.0.6/+download/employees_db-full-1.0.6.tar.bz2

tar -xjf employees_db-full-1.0.6.tar.bz2

cd employees_db

vim employees.sql
    把 storage_engine 改为 default_storage_engine

mysql -t < employees.sql -uroot -proot


========================== mysql 技术内幕 innodb 存储引擎 ==============================

drop table if exists t;

create table t(
   a int unsigned not null auto_increment,
   b char(10),
   primary key(a)
)engine=innodb charset=utf8;

delimiter //
create procedure load_t(count int unsigned)
  BEGIN
     SET @c = 0;
     WHILE @c < count DO
      INSERT INTO t SELECT NULL,REPEAT(CHAR(97+RAND() * 26),10);
      SET @c = @c + 1;
     END WHILE;
  END;
  //
DELIMITER ;

CLASS load_t(100);

select a,b from limit 10;

-------------

select @@version\G;
show variables like'innodb_version'\G;
show variables like'innodb_file_format'\G;

--------------

CREATE TABLE u(
  id INT,
  name VARCHAR(20),
  id_card CHAR(18),
  PRIMARY KEY(id),
  UNIQUE KEY(name)
);

SELECT constraint_name,constraint_type FROM information_schema.TABLE_CONSTRAINTS WHERE table_schema='test' AND table_name='u';\G;

ALTER TABLE u ADD UNIQUE KEY uk_id_card(id_card);

CREATE TABLE p(
  id INT,
  u_id INT,
  PRIMARY KEY(id),
  FOREIGN KEY(u_id) REFERENCES p(id)
);

SELECT constraint_name,constraint_type FROM information_schema.TABLE_CONSTRAINTS WHERE table_schema='test' AND table_name='p';\G;

SELECT * FROM information_schema.REFERENTIAL_CONSTRAINTS WHERE constraint_schema='test'\G;


-------------

CREATE TABLE a(
  id INT NOT NULL,
  date DATE NOT NULL
);

INSERT INTO a SELECT NULL,'2009-02-30';

SHOW VARIABLES LIKE'sql_mode';

----------------


CREATE TABLE a(
  id INT,
  sex ENUM('male','female')
);

INSERT INTO a SELECT 1,'female';
INSERT INTO a SELECT 2,'bi';

--------------- 触发器 -----------------

CREATE
[DEFINER={user|CURRENT_USER}]
TRIGGER trigger_name BEFORE|AFTER INSERT|UPDATE|DELETE
ON tbl_name FOR EACH ROW trigger_stmt

CREATE TABLE usercash(
  userid INT NOT NULL,
  cash INT UNSIGNED NOT NULL
);

INSERT INTO usercash SELECT 1,1000;

UPDATE usercash SET cash=cash-(-20) WHERE userid=1;

CREATE TABLE usercash_err_log(
  userid INT NOT NULL,
  old_cash INT UNSIGNED NOT NULL,
  new_cash INT UNSIGNED NOT NULL,
  user VARCHAR(30),
  time DATETIME
);

DELIMITER //
CREATE TRIGGER tgr_usercash_update BEFORE UPDATE ON usercash
FOR EACH ROW
  BEGIN
      IF new.cash - old.cash > 0 THEN
      INSERT INTO usercash_err_log
      SELECT old.userid,old.cash,new.cash,USER(),NOW();
      SET new.cash = old.cash;
    END IF;
  END;
//
DELIMITER ;

DELETE FROM usercash;
INSERT INTO usercash SELECT 1,1000;
UPDATE usercash SET cash=cash - (-20) WHERE userid=1;
SELECT * FROM usercash\G;


-------------------- 外键约束

[CONSTRAINT[symbol]] FOREIGN KEY
[index_name](index_col_name,...)
REFERENCES tbl_name(index_col_name,...)
[ON DELETE reference_option]
[ON UPDATE reference_option]
reference_option:
RESTRICT|CASCADE|SET NULL|NO ACTION

/*
CASCADE 当父表发生 delete 或 update 时，子表数据进行相应的操作
SET NULL 父表发生 update 或 delete 时，子表数据更新为null值
NO ACTION 父表发生 update 或 delete 时，抛出错误，不允许这类操作发生
RESTRICT 父表发生 update 或 delete 时，抛出错误，不允许这类操作发生
*/

CREATE TABLE parent(
  id INT NOT NULL,
  PRIMARY KEY(id)
)ENGINE=INNODB;

CREATE TABLE child(
  id INT,
  parent_id INT,
  FOREIGN KEY(parent_id) REFERENCES parent(id)
)ENGINE=INNODB;

/*导入数据时忽略外键检查*/

SET foreign_key_checks = 0;
LOAD DATA......
SET foreign_key_checks = 1;


------------------- 视图

CREATE
[OR REPLACE]
[ALGORITHM={UNDEFINED|MERGE|TEMPTABLE}]
[DEFINER={user|CURRENT_USER}]
[SQL SECURITY{DEFINER|INVOKER}]
VIEW view_name[(column_list)]
AS select_statement
[WITH[CASCADED|LOCAL]CHECK OPTION]

CREATE TABLE t(
  id INT
);

CREATE VIEW v_t AS SELECT * FROM t WHERE id < 10;

INSERT INTO v_t SELECT 20;

SELECT * FROM v_t;

ALTER TABLE v_t AS SELECT * FROM t WHERE id < 10 WITH CHECK OPTION;

INSERT INTO v_t SELECT 20;

SELECT * FROM information_schema.TABLES WHERE table_type='BASE TABLE' AND table_schema=database() \G;


--------------- 物化视图


CREATE TABLE orders
(
  order_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_name VARCHAR(30) NOT NULL,
  price DECIMAL(8,2) NOT NULL,
  amount SMALLINT NOT NULL,
  PRIMARY KEY(order_id)
)ENGINE=InnoDB;

INSERT INTO orders VALUES
(NULL,'CPU',100.2,1),
(NULL,'Memory',101.2,3),
(NULL,'CPU',102.2,3),
(NULL,'CPU',103.2,1);

SELECT * FROM orders \G;

CREATE TABLE orders_mv(
  product_name VARCHAR(30) NOT NULL,
  price_sum DECIMAL(8,2) NOT NULL,
  amount_sum INT NOT NULL,
  price_avg FLOAT NOT NULL,
  orders_cnt INT NOT NULL,
  UNIQUE INDEX(product_name)
);

INSERT INTO orders_mv SELECT product_name,SUM(price),SUM(amount),AVG(price),COUNT(*) FROM orders GROUP BY product_name;

SELECT * FROM orders_mv \G;

------------------------ 分区表

SHOW PLUGINS\G;

/*
  水平分区：指将同一表中不同行得记录分配到不同的物理文件中
  垂直分区：指将同一表中不同列得记录分配到不通的物理文件中

  RANGE 行数据基于属于一个给定连续区间的列值被放入分区。mysql 5.5 开始支持 RANGE COLUMNS的分区
  LIST  和RANGE 分区类似，只是LIST分区面向的是离散的值。 mysql 5.5 开始支持 LIST COLUMNS 的分区
  HASH  根据用户自定义的表达式的返回值来进行分区，返回值不能为负数
  KEY   根据mysql数据库提供的哈希函数来进行分区
*/

/*不论创建何种类型的分区，如果表中存在主键或者唯一索引时，分区列必须是唯一索引的一个组成部分，因此下面创建分区的sql语句会产生错误*/
CREATE TABLE t1(
 a int,
 b date,
 c int,
 d INT,
 unique key(a,b)
)
partition by hash(c)
partitions 4;

/*唯一索引是允许null值得，并且分区列只要是唯一索引得一个组成部分，不需要整个唯一索引列都是分区，如：*/
CREATE TABLE t1(
 a int,
 b date,
 c int,
 d INT,
 unique key(a,b,c,d)
)
partition by hash(c)
partitions 4;

-- 如果建表时没有指定主键，唯一索引，可以指定任何一个列为分区列
CREATE TABLE t1(
 a int,
 b date,
 c int,
 d INT
)
partition by hash(c)
partitions 4;

CREATE TABLE t1(
 a int,
 b date,
 c int,
 d INT,
 key(d)
)
partition by hash(c)
partitions 4;


-------------------- range 分区

CREATE TABLE t(id INT)ENGINE=INNODB
PARTITION BY RANGE(id)(
  PARTITION p0 VALUES LESS THAN(10),
  PARTITION p1 VALUES LESS THAN(20)
);

-- 查看表在磁盘上的物理文件，启用分区之后，表不再由一个idb文件组成了，而是由建立分区时的各个分区idb文件组成，如 t#P#p0.idb,t#P#p1.idbqq
system ls -lh /var/lib/mysql/test/t*;

INSERT INTO t SELECT 9;
INSERT INTO t SELECT 10;
INSERT INTO t SELECT 15;

SELECT * FROM information_schema.PARTITIONS WHERE table_schema=database() AND table_name='t'\G;

ALTER TABLE t ADD PARTITION(
  PARTITION p2 VALUES LESS THAN MAXVALUE
);

-- RANGE 分区主要用于日期列的分区，例如对于销售类的表，可以根据年来分区存放销售记录，如下面的分区表 sales
CREATE TABLE sales(
  money INT UNSIGNED NOT NULL,
  date DATETIME
)ENGINE=INNODB
PARTITION BY RANGE(YEAR(date))(
  PARTITION p2015 VALUES LESS THAN(2016),
  PARTITION p2016 VALUES LESS THAN(2017),
  PARTITION p2017 VALUES LESS THAN(2018)
);

INSERT INTO sales SELECT 100,'2015-01-01';
INSERT INTO sales SELECT 100,'2015-02-01';
INSERT INTO sales SELECT 100,'2016-01-01';
INSERT INTO sales SELECT 100,'2016-02-01';
INSERT INTO sales SELECT 100,'2017-01-01';
INSERT INTO sales SELECT 100,'2017-02-01';

-- 查询2017整年的销售额  （SQL 语句只会去搜索p2017这个分区）
EXPLAIN PARTITIONS
SELECT * FROM sales WHERE date>='2017-01-01' AND date<='2018-12-31'\G;

-- 下面这条sql 会搜索 2016 和 2017 两个分区
EXPLAIN PARTITIONS
SELECT * FROM sales WHERE date>='2016-01-01' AND date<='2017-12-31'\G;

-- 删除2017年的数据
ALTER TABLE sales DROP PARTITION p2015;


CREATE TABLE sales1(
  money INT UNSIGNED NOT NULL,
  date DATETIME
)ENGINE=INNODB
PARTITION BY RANGE(YEAR(date) * 100 + MONTH(date))(
  PARTITION p2010001 VALUES LESS THAN(2010002),
  PARTITION p2010002 VALUES LESS THAN(2010003),
  PARTITION p2010003 VALUES LESS THAN(2010004)
);

-- 下面这条sql对 所有分区都进行了搜索
EXPLAIN PARTITIONS
SELECT * FROM sales1 WHERE date>='2010-01-01' AND date<='2010-01-31'\G;

-- 对于range分区的查询，优化器只能对 YEAR() TO_DAYS(),TO_SECONDS(),UNIX_TIMESTAMP() 这类函数进行优化选择
CREATE TABLE sales1(
  money INT UNSIGNED NOT NULL,
  date DATETIME
)ENGINE=INNODB
PARTITION BY RANGE(TO_DAYS(date))(
  PARTITION P2010001 VALUES LESS THAN(TO_DAYS('2010-02-01')),
  PARTITION P2010002 VALUES LESS THAN(TO_DAYS('2010-03-01')),
  PARTITION P2010003 VALUES LESS THAN(TO_DAYS('2010-04-01'))
);

EXPLAIN PARTITIONS
SELECT * FROM sales WHERE date>='2010-01-01' AND date<='2010-01-31'\G;



------------------------------- LIST 分区 ---------------------------------------

-- list 分区和range分区非常相似，只是分区列的值是离散的，而非连续的

CREATE TABLE t(
  a INT,
  b INT
)ENGINE=INNODB
PARTITION BY LIST(b)(
  PARTITION P0 VALUES IN(1,3,5,7,9),
  PARTITION P1 VALUES IN(2,4,6,8,10)
);

-- 不同于range分区定义的values less than 语句 ，list 分区使用 values in。因为每个分区的值是离散的，因此只能定义值

INSERT INTO t SELECT 1,1;
INSERT INTO t SELECT 1,2;
INSERT INTO t SELECT 1,3;
INSERT INTO t SELECT 1,4;
INSERT INTO t SELECT 1,5;
INSERT INTO t SELECT 1,6;
INSERT INTO t SELECT 1,7;
INSERT INTO t SELECT 1,8;
INSERT INTO t SELECT 1,9;
INSERT INTO t SELECT 1,10;

SELECT table_name,partition_name,table_rows FROM information_schema.PARTITIONS WHERE table_name='t' AND table_schema=DATABASE() \G;

-- 如果插入的值不再分区的定义中，会抛出异常
INSERT INTO t SELECT 1,11;


------------------------------------------- HASH 分区 ---------------------------------------------------

-- hash 分区的目的是将数据均匀的分不到预先定义的各个分区中。在 range 和 list分区中，必须明确指定一个给定的列值或列值集合应该保存到那个分区中；而在hash分区中，mysql自动完成这些工作。用户所要做的只是基于将要进行哈希分区的列值指定一个列值或表达式，以及指定分区的表将要被分割成的分区数量

CREATE TABLE t_hash(
  a INT,
  b DATETIME
)ENGINE=INNODB
PARTITION BY HASH(YEAR(b))
PARTITIONS 4;

INSERT INTO t_hash SELECT 1,'2010-04-01';

-- 可以看到 p2 分区有一条记录 。如果对于连续的值进行hash分区，如自增长的主键，则可以较好的将数据进行平均分布
SELECT table_name,partition_name,table_rows FROM information_schema.PARTITIONS WHERE table_schema=DATABASE() AND table_name='t_hash'\G;

-- LINEAR HASH 分区
-- linear hash 分区的有点在于，增加，删除，合并和拆分分区将变得更加快捷，这有利于处理含有大量数据的表。它的缺点在于，于使用hash分区得到的数据分布相比，各个分区间数据的分布可能不大均匀

CREATE TABLE t_linear_hash(
  a INT,
  b DATETIME
)ENGINE=INNODB
PARTITION BY LINEAR HASH(YEAR(b))
PARTITIONS 4;

INSERT INTO t_linear_hash SELECT 1,'2010-04-01';

SELECT table_name,partition_name,table_rows FROM information_schema.PARTITIONS WHERE table_schema=DATABASE() AND table_name='t_linear_hash'\G;



------------------------------------------- key 分区 ---------------------------------------------------

-- key分区和hash分区相似，不同之处在于hash分区使用用户定义的函数进行分区，key分区使用mysql数据库提供的函数进行分区。对于NDB Cluster 引擎，msyql数据库使用md5函数来分区；对于其他存储引擎，mysql数据库使用其内部的哈希函数，这些函数基于与 PASSWORD() 一样的算法

CREATE TABLE t_key(
  a INT,
  b DATETIME
)ENGINE=INNODB
PARTITION BY KEY(b)
PARTITIONS 4;

------------------------------------------- COLUMNS 分区 ---------------------------------------------------

-- RANGE,LIST,HASH,KEY 中分区条件是：数据必须是整型，如果不是整型，需要通过函数将其转化为整型，如 year() to_days() month() 等。mysql5.5开始支持COLUMNS分区，可视为range分区和list分区的一种进化。columns分区可以直接使用非整型的数据进行分区，分区根据类型直接比较而得，不需要转化为整型。此外，rangecolumns 分区可以对多个列得值进行分区

-- 所有的整型类型，如 INT SMALLINT TINYINT BIGINT    (FLOAT DECIMAL 不支持)
-- 日期类型，如 DATE DATETIME                       (其余的日期类型不予支持)
-- 字符串类型，如 CHAR VARCHAR BINARY VARBINARY      (BLOB TEXT 类型不予支持)
-- 对于日期类型的分区，我们不需要YEAR() TO_DAYS() 函数了，而直接可以使用 COLUMNS

CREATE TABLE t_columns_range(
  a INT,
  b DATETIME
)ENGINE=INNODB
PARTITION BY RANGE COLUMNS(b)(
  PARTITION P0 VALUES LESS THAN('2009-01-01'),
  PARTITION P1 VALUES LESS THAN('2010-01-01')
);

-- 可以直接使用字符串的分区
CREATE TABLE customers_1(
  first_name VARCHAR(25),
  last_name VARCHAR(25),
  street_1 VARCHAR(30),
  street_2 VARCHAR(30),
  city VARCHAR(15),
  renewal DATE
)
PARTITION BY LIST COLUMNS(city)(
  PARTITION P0 VALUES IN('bj','sh','gz'),
  PARTITION P1 VALUES IN('tj','xa','cq'),
  PARTITION P2 VALUES IN('ty','cz','lf')
);

--  使用多个列进行分区
CREATE TABLE rcx(
  a int,
  b int,
  c char(3),
  d int
)Engine=InnoDB
PARTITION BY RANGE COLUMNS(a,d,c)(
  PARTITION P0 VALUES LESS THAN(5,10,'aaa'),
  PARTITION P1 VALUES LESS THAN(5,10,'bbb'),
  PARTITION P2 VALUES LESS THAN(5,10,'ccc'),
  PARTITION P3 VALUES LESS THAN(5,10,'ddd'),
  PARTITION P4 VALUES LESS THAN(MAXVALUE,MAXVALUE,MAXVALUE)
);

-- MYSQL5.5 开始支持columns分区，对于之前range和list分区，用户可以用range columns和list columns分区进行很好的代替

------------------------------------------- 子分区 ---------------------------------------------------

CREATE TABLE ts(a INT,b DATE)ENGINE=INNODB
PARTITION BY RANGE(YEAR(b))
SUBPARTITION BY HASH(TO_DAYS(b))
SUBPARTITIONS 2(
  PARTITION P0 VALUES LESS THAN(1990),
  PARTITION P1 VALUES LESS THAN(2000),
  PARTITION P2 VALUES LESS THAN MAXVALUE
);

system ls -lh /var/lib/mysql/test/ts*;

CREATE TABLE ts(a INT, b DATE)
PARTITION BY RANGE(YEAR(b))
SUBPARTITION BY HASH(TO_DAYS(b))(
  PARTITION P0 VALUES LESS THAN(1990)(
    SUBPARTITION S0,
    SUBPARTITION S1
  ),
  PARTITION P1 VALUES LESS THAN(2000)(
    SUBPARTITION S2,
    SUBPARTITION S3
  ),
  PARTITION P2 VALUES LESS THAN MAXVALUE(
    SUBPARTITION S4,
    SUBPARTITION S5
  )
);

-- 子分区可以用于特别大的表，在多个磁盘间分别分配数据和索引。假设有6个磁盘，分别为 /disk0,/disk1,/disk2 等
CREATE TABLE ts(a INT,b DATE)ENGINE=INNODB
PARTITION BY RANGE(YEAR(b))
SUBPARTITION BY HASH(TO_DAYS(b))(
  PARTITION P0 VALUES LESS THAN(2000)(
    SUBPARTITION S0
    DATA DIRECTORY='/disk0/data'
    INDEX DIRECTORY='/disk0/idx',
    SUBPARTITION S1
    DATA DIRECTORY='/disk1/data'
    INDEX DIRECTORY='/disk1/idx'
  ),
  PARTITION P1 VALUES LESS THAN(2010)(
    SUBPARTITION S2
    DATA DIRECTORY='/disk2/data'
    INDEX DIRECTORY='/disk2/idx',
    SUBPARTITION S3
    DATA DIRECTORY='/disk3/data'
    INDEX DIRECTORY='/disk3/idx'
  ),
  PARTITION P2 VALUES LESS THAN MAXVALUE(
    SUBPARTITION S4
    DATA DIRECTORY='/disk4/data'
    INDEX DIRECTORY='/disk4/idx',
    SUBPARTITION S5
    DATA DIRECTORY='/disk5/data'
    INDEX DIRECTORY='/disk5/idx'
  )
);


------------------------------------------- 分区中的NULL值 ---------------------------------------------------

CREATE TABLE t_range(
  a INT,
  b INT
)ENGINE=INNODB
PARTITION BY RANGE(b)(
  PARTITION P0 VALUES LESS THAN(10),
  PARTITION P1 VALUES LESS THAN(20),
  PARTITION P2 VALUES LESS THAN MAXVALUE
);


INSERT INTO t_range SELECT 1,1;
INSERT INTO t_range SELECT 1,null;

SELECT table_name,partition_name,table_rows FROM information_schema.PARTITIONS WHERE table_schema=DATABASE() AND table_name='t_range'\G;

-- 可以看到两条数据都放入了P0分区，也就是说明了range分区下，NULL 值会放入最左边的分区中。另外需要注意的是，如果删除这个分区，删除的将是小于10的记录，并且还有NULL值的记录，这点非常重要

ALTER TABLE t_range DROP PARTITION P0;

SELECT * FROM t_range;

-- list 分区下要使用null值，必须显示的指出哪个分区中放入null值，否则会报错
CREATE TABLE t_list(
  a INT,
  b INT
)ENGINE=INNODB
PARTITION BY LIST(b)(
  PARTITION P0 VALUES IN(1,3,5,7,9),
  PARTITION P1 VALUES IN(2,4,6,8)
);

INSERT INTO t_list SELECT 1,NULL;

-- 若P0分区允许null值，则插入不会报错
CREATE TABLE t_list(
  a INT,
  b INT
)ENGINE=INNODB
PARTITION BY LIST(b)(
  PARTITION P0 VALUES IN(1,3,5,7,9,NULL),
  PARTITION P1 VALUES IN(2,4,6,8)
);

INSERT INTO t_list SELECT 1,NULL;

SELECT table_name,partition_name,table_rows FROM information_schema.PARTITIONS WHERE table_schema=DATABASE() AND table_name='t_list'\G;

-- hash 和 key 分区对于 NULL 值得处理方式和range list 分区不一样。任何分区函数都会将含有NULL值得记录返回为0
CREATE TABLE t_hash(
  a INT,
  b INT
)ENGINE=INNODB
PARTITION BY HASH(b)
PARTITIONS 4;

INSERT INTO t_hash SELECT 1,0;
INSERT INTO t_hash SELECT 1,NULL;

SELECT table_name,partition_name,table_rows FROM information_schema.PARTITIONS WHERE table_schema=DATABASE() AND table_name='t_hash'\G;


-------------------------------- 表和分区间交换数据 ----------------------------------

  create table e(
    id int not null,
    fname varchar(30),
    lname varchar(30)
  )
  partition by range(id)(
    partition p0 values less than(50),
    partition p1 values less than(100),
    partition p2 values less than(150),
    partition p3 values less than maxvalue
  );

insert into e values(1669,'jim','smith'),(337,'aaa','bbb'),(16,'ccc','ddd'),(2005,'eee','fff');

create table e2 like e;

alter table e2 remove partitioning;

SELECT PARTITION_NAME,TABLE_ROWS FROM information_schema.partitions where table_name='e';

alter table e exchange partition p0 with table e2;

SELECT PARTITION_NAME,TABLE_ROWS FROM information_schema.partitions where table_name='e';


ALTER TABLE tbl_name
ADD {INDEX|KEY} [index_name]
[index_type](index_col_name,...)[index_option]...

ALTER TABLE tbl_name
DROP PRIMARY KEY
| DROP {INDEX|KEY} index_name

CREATE [UNIQUE] INDEX index_name
[index_type]
ON tbl_name(index_col_name,...)
DROP INDEX index_name ON tbl_name

ALTER TABLE t ADD KEY idx_b(b(100));

analyze table t1;

-------------------------------- 联合索引 ----------------------

CREATE TABLE buy_log(
  userid INT UNSIGNED NOT NULL,
  buy_date DATE
)ENGINE=INNODB;

INSERT INTO buy_log VALUES(1,'2009-01-01');
INSERT INTO buy_log VALUES(2,'2009-01-01');
INSERT INTO buy_log VALUES(3,'2009-01-01');
INSERT INTO buy_log VALUES(1,'2009-02-01');
INSERT INTO buy_log VALUES(3,'2009-02-01');
INSERT INTO buy_log VALUES(1,'2009-03-01');
INSERT INTO buy_log VALUES(1,'2009-04-01');

ALTER TABLE buy_log ADD KEY(userid);
ALTER TABLE buy_log ADD KEY(userid,buy_date);

EXPLAIN SELECT * FROM buy_log WHERE userid = 2;

EXPLAIN SELECT * FROM buy_log WHERE userid = 1 ORDER BY buy_date DESC LIMIT 3;


---------------------- 逻辑备份 ---------------------
mysqldump [arguments] > file_name
msyqldump --all-databases > dump.sql
mysqldump --databases db1 db2 db3 > dump.sql

--single-transaction  在备份开始之前，先执行 START TRANSACTION命令，以此来获得备份的一致性，当前该参数只对innodb存储引擎有效。当启用该参数进行备份时，确保没有其他任何DDL语句执行，因为一致性读并不能隔离DDL操作。

--lock-tables(-1)
    -- 在备份中，依次锁住每个架构下的所有表。一般用于myisam引擎，当备份时只能对数据库进行读取操作，不过备份依然可以保证一致性。对于innodb，不需要使用该参数，用 --single-transaction即可。如果既有myisam，又有innodb的表，只能用 --lock-talbes。

--lock-all-tables(-x)
    -- 在备份过程中，对所有架构中的所有表上锁。这个可以避免--lock-tables参数不能同时锁住所有表的问题

--add-drop-database
    -- 在CREATE DATABASE 前先运行 DROP DATABASE。这个参数需要和 --all-databases 或者 --databases 选项一起使用。在默认情况下，导出的文本文件中并不会有CREATE DATABASE,除非指定了这个参数

--master-data=[value]
    -- 通过该参数产生的备份转存文件主要用来建立一个replication。当value的值为1时，转存文件中记录的CHANGE MASTER语句。当value的值为2时，CHANGE MASTER语句被写出SQL注释。

--master-data
    -- 会自动忽略 --lock-tables 选项。如果没有使用--single-transcation选项，则会自动使用--lock-all-tables选项。

--events
    -- 备份事件调度器

--routines
    -- 备份存储过程和函数

--triggers
    -- 备份触发器

--hex-blob
    -- 将 BINARY VARBINARY BLOG BIT 列类型备份为十六进制的格式。mysqldump导出的文件一般时文本文件，但是如果导出的数据类型中有上述这些类型，在文本文件模式下可能有些字符不可见，若添加--hex-blob选项，结果会以十六进制的方式显示



----------------------- SELECT ... INTO OUTFILE ---------------------------


show variables like '%secure%';

select * into outfile '/var/lib/mysql-files/t.sql' from t;

mysql > test.sql -u root -p

load data infile '/home/lgl/t.sql' into table t;

SET@@foreign_key_checks = 0;
LOAD DATA INFILE'/home/lgl/t.sql' INTO TABLE t;
SET@@foreign_key_checks = 1;

CREATE TABLE b(a INT, b INT, c INT,PRIMARY KEY(a))ENNGINE=INNODB;
LOAD DATA INFILE'/home/lgl/b.sql' INTO TABLE b FIELDS TERMINATED BY ','(a,b) SET c=a+b;
SELECT * FROM b;

mysqlimport [options] db_name textfile1 [textfile2] ....
mysqlimport --use-threads=2 test /home/lgl/a.sql /home/lgl/b.sql

SHOW FULL PROCESSLIST \G;

-------------- 二进制日志备份与恢复 ------------------

-- 推荐配置
[mysqld]
log-bin = mysql-bin
sync_binlog = 1
innodb_support_xa = 1

-- 在备份二进制文件之前，可以通过 FLUSH LOGS 来生成一个新的二进制日志文件，然后备份之前的二进制日志

-- 恢复
mysqlbinlog [options] log_file ...

mysqlbinlog binlog.0000001 | mysql -u root -p test

--------------- 主从--------------

SHOW FULL PROCESSLIST \G;
SHOW MASTER STATUS;
SHOW SLAVE STATUS;

-- 建议开启从服务上的 read-only 选项，这样能保证从服务器上的数据仅与主服务进行同步 避免其他线程修改数据
[mysqld]
read-only

------------------------------ 事务 ------------------------------------


CREATE TABLE test_load(
a INT,
b CHAR(10)
)ENGINE=INNODB;
ALTER TABLE test_load modify COLUMN b CHAR(200);

DELIMITER //
CREATE PROCEDURE p_load(count INT UNSIGNED)
BEGIN
DECLARE s INT UNSIGNED DEFAULT 1;
DECLARE c CHAR(80) DEFAULT REPEAT('a',80);
WHILE s <= count DO
INSERT INTO test_load SELECT NULL,c;
COMMIT;
SET s = s+1;
END WHILE;
END;
//
DELIMITER ;

CALL p_load(500000);


show variables like 'innodb_flush_log_at_trx_commit'\G;
set global innodb_flush_log_at_trx_commit=0;
CALL p_load(5000);



CREATE TABLE t(a int,primary key(a))engine=innodb;

select @@autocommit \G;

set @@completion_type = 1;

BEGIN;
  insert into t select 1;
  commit work;

  insert into t select 2;
  insert into t select 2;
  rollback;

  select * from t;














































