<?php

/*
 * 1 PDO 类
 *
 * PDO                  构造器
 * beginTransaction     开始事务
 * commit               提交事务
 * errorCode            从数据库返回一个错误代码，如果有的话
 * errorInfo            从数据库返回一个含有错误信息的数组，如果有的话
 * exec                 执行一条sql语句并返回影响的行数
 * getAttribute         返回一个数据库连接属性
 * lastInsertId         返回最新插入到数据库的行（id）
 * prepare              为执行准备一条sql语句，返回语句执行后的联合结果集（PDOStatement)
 * query                执行一条sql语句并返回一个结果集
 * quote                返回添加引号的字符串，使其可用于sql语句中
 * rollBack             回滚一个事务
 * setAttribute         设置一个数据库连接属性
 *
 * 2 PDOStatement 类
 *
 * PDOStatement 类代表一条预处理语句以及语句执行后的联合结果集
 * bindColumn           绑定一个php变量到结果集中的输出列
 * bindParam            绑定一个php变量到一个预处理
 * bindValue            绑定一个值到与处理语句中的参数
 * closeCursor          关闭游标，使语句可以再次执行
 * columnCount          返回结果集中的列的数量
 * errorCode            从语句中返回一个错误代号，如果有的话
 * errorInfo            从语句中返回一个包含错误信息的数组，如果有的话
 * execute              执行一条预处理语句
 * fetch                从结果集中取出一行
 * fetchAll             从结果集中取出一个包含所有行的数组
 * fetchColumn          返回结果集中某一列的数据
 * getAttribute         返回一个PDOStatement属性
 * getColumnMeta        返回结果集中某一列的结构
 * nextRowset           返回下一个结果集
 *
 * */













