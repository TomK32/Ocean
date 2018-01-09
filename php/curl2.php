<?php
$url = "http://www.test.com:8081/Ocean/php/post.php";

$post_data = array(
    'foo'=>'bar',
    'query'=>'php',
    'action'=>'submit'
);

$ch = curl_init();
curl_setopt($ch,CURLOPT_URL,$url);
curl_setopt($ch,CURLOPT_RETURNTRANSFER,1);

curl_setopt($ch,CURLOPT_POST,1);

curl_setopt($ch,CURLOPT_POSTFIELDS,$post_data);

$output = curl_exec($ch);
curl_close($ch);
echo $output;
