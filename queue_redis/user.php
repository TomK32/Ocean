<?php

$redis = new Redis();

$redis->connect('127.0.0.1',6379);

$redis_name = 'miaosha';

//模拟数据
for($i = 0; $i < 100; $i++){
	$uid = rand(100000,999999);

	// 获取用户的id
	#$uid = $_GET['uid'];

	$num = 10;

	//获取一下redis里面已由的数量
	if($redis->lLen($redis_name) < 10){
		//如果当天人数少于十的时候，则加入这个队列
		$redis->rPush($redis_name,$uid.'%'.microtime());
		echo $uid . ' 秒杀成功';
	}else{
		//如果当天人数已经达到了10人，则返回秒杀已完成
		echo "秒杀已经结束";
	}	
}

$redis->close();

