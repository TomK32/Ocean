<?php

//简单得 http 协议使用示例

$html = file_get_contents('http://www.baidu.com/');
print_r($html);

$fp = fopen('http://www.baidu.com/','r');
print_r(stream_get_meta_data($fp));