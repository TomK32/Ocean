<?php
// http 构造灌水机器人

$data = array("author"=>"king","mail"=>"a@a.com","text"=>"aaa");
$data = http_build_query($data);

$opts = array(

    "http"=>array(
        "method"=>"POST",
        "header"=>
            "Content-type:application/x-www-form-urlencoded"."\r\n".
            "Content-Length:".strlen($data)."\r\n".
            "Cookie:PHPSESSID=rsg2pue0db129me4crpcfo8tc6"."\r\n".
            "User-Agent:Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36"."\r\n".
            "Referer:http://www.test.com:8086/Ocean/php/get.php"."\r\n",
        "content"=>$data
    ),
);

$context = stream_context_create($opts);

$html = file_get_contents("http://www.test.com:8086/Ocean/php/get.php",false,$context);

print_r($html);


