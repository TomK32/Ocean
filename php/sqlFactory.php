<?php
class sqlFactory
{
    public static function factory($type)
    {
        if(include_once 'Db_Adapter_'.$type.'.php'){
            $classname = 'Db_Adapter_'.$type;
            return new $classname;
        }else{
            throw new Exception('Driver not found');
        }
    }
}

$db = sqlFactory::factory('Mysql');

$a = new $db();
$c = $a->connect(array('host'=>'localhost','user'=>'root','pass'=>'root','database'=>'test','port'=>3306));
$res = $c->query('select * from user');
$res = $res->fetch_all();
var_dump($res);
