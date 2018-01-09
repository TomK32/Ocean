<?php

$str = "[url]1.gif[/url][url]2.gif[/url][url]3.gif[/url]";

$s = preg_replace("#\[url\](?<WORD>\d\.gif)\[\/url\]#","<img src=/upload/$1>",$str);

$s1 = preg_replace("#\[url\](.*?)\[\/url\]#","<img src=/upload/$1>",$str);

$reg = "#<a[^>]*>([^<>]*)<\/a>#";
$str = "<a href='http://www.baidu.com'>baidu</a>some<a href='http://sohu.com'>sohu</a>";
preg_match_all($reg,$str,$m);

$str = "<Div>gG</Div>";
if(preg_match('%<div>gg<\/div>%i',"<Div>gG</Div>",$arr)){
    echo $arr[0];
}else{
    echo 'wrong';
}

$a = 'abc\nabcd';
$b = "abc\nabcd";

if(preg_match_all('%^abc%m',$a,$arr)){
    var_dump($arr);
}

if(preg_match_all('%^abc%m',$b,$arr)){
    var_dump($arr);
}


$str = 'php 编程';
if(preg_match("/^[\x{4e00}-\x{9fa5}]+$/u",$str)){
    echo 'all chinese';
}else{
    echo 'not all chinese';
}

$mobile = '13500000000';
$regex = "/^1[358]\d{9}/";
if(!preg_match($regex,$mobile)){
    echo 'wrong';
}else{
    echo 'yes';
}

$reg = "\w{3,16}@\w{1,64}\.\w{2,5}";




















