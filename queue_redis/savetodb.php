<?php

$db = new mysqli('localhost','root','root','test');

$redis = new Redis();
$redis->connect('127.0.0.1',6379);
$redis_name = 'miaosha';

//死循环
while(1){
	
	//从队列最左侧取出一个值来
	$user = $redis->lPop($redis_name);
	
	//然后后判断这个值是否存在
	if(!$user || $user == 'nil'){
		sleep(2);
		continue;
	}

	//切割出时间 uid
	$user_arr = explode('%',$user);
	$uid = $user_arr[0];
	$time_stamp = $user_arr[1];

	//保存到数据库中
	$res = $db->query("insert into redis_queue(uid,time_stamp) value($uid,'$time_stamp')");

	//数据库插入失败的时候的回滚机制
	if(!$res){
		$redis->rPush($reids_name,$user);
	}
	
	sleep(2);
}
	//释放一下redis
	$redis->close();
























