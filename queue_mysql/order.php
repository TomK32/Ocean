<?php

include 'db.php';

ini_set('display_errors','On');

$db = new mysqli('localhost','root','root','test');

if(!empty($_GET['mobile'])){
	
	$order_id = rand(10000,99999);
	$mobile = $_GET['mobile'];
	$date = date('Y-m-d H:i:s');
	$status = 0;


	$sql = "insert into order_queue(order_id,mobile,created_at,status) value('$order_id','$mobile','$date',$status)";

	$res = $db->query($sql);

	var_dump($res);
	exit;

	if($res){
		echo $order_id . " save success";
	}else{
		echo 'save error';
	}

}

