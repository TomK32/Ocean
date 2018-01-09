<?php

// 初始化
$ch = curl_init();

//设置选项，包括url
curl_setopt($ch,CURLOPT_URL,"http://www.baidu.com");

//将 curl_exec() 获取的信息以文件流的形式返回，而不是直接输出
curl_setopt($ch,CURLOPT_RETURNTRANSFER,1);

//启用时会将头文件的信息作为数据流输出
curl_setopt($ch,CURLOPT_HEADER,1);

//执行并获取 HTML 文档内容
$output = curl_exec($ch);

if($output === FALSE)
{
    echo "curl Error:" . curl_error($ch);
}

$info = curl_getinfo($ch);
echo '获取'.$info['url'].'耗时'.$info['total_time'].'秒';

print_r($info);

//释放curl句柄
curl_close($ch);

echo $output;