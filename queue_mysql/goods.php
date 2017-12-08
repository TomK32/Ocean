<?php

ini_set('display_errors','On');

$db = new mysqli('localhost','root','root','test');

// 把要处理的记录更新为等待处理

$sql = "update order_queue set status=2 where status=0 order by id desc limit 1";

#$waiting = array('status'=>1);
#$lock = array('status'=>2);

$res_lock = $db->query($sql);

$res_lock = mysqli_affected_rows($db);

// 选择出刚刚更新的这些数据，然后进行配送系统的处理
if($res_lock){
	//选择出要处理的订单的内容

	$res = $db->query("select * from order_queue where status=2");

	while($row = mysqli_fetch_assoc($res)){
		$data[] = $row;
	}
	//然后由配货系统进行配货处理

	//处理完成之后把订单更新为已处理
	$status = 1;
	$update_at = date('Y-m-d H:i:s',time());

	$res_up = $db->query("update order_queue set status=1,updated_at='$update_at' where status=2");

	if($res_up){
		echo "success : " . $res_up;
	}else{
		echo "error : " . $res_up;
	}
}else{
	echo "All finished";
}

//
//
