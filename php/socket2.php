<?php

$host = '127.0.0.1';
$port = 8080;

set_time_limit(0);      //最好在cli模式下运行，保证服务不会超时

$socket = socket_create(AF_INET,SOCK_STREAM,0);     # 创建socket

$result = socket_bind($socket,$host,$port);         # 绑定socket到指定地址和端口

$result = socket_listen($socket,3);                 # 开始监听连接

$spawn = socket_accept($socket);                    # 接受连接请求并调用另一个子socket处理客户端-服务器间的信息

$input = socket_read($spawn,1024);                  # 读取客户端输入

$input = trim($input);

$output = strrev($input)."\n";                      # 反转客户端输入数据，返回服务端

socket_write($spawn,$output,strlen($output));

socket_close($spawn);
socket_close($socket);