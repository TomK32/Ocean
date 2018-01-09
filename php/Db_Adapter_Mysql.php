<?php
/**
 * 单一职责原则
 * 接口隔离原则
 * 开放-封闭原则
 * 替换原则
 * 依赖倒置原则
 */

interface Db_Adapter
{
    /*
     * 数据库连接
     * @param $config 数据库配置
     * @return resource
     * */

    public function connect($config);

    /*
     * 执行数据库查询
     * @param string $query 数据库查询 SQL 字符串
     * @param mixed $handle 连接对象
     * @return resource
     * */
    public function query($query,$handle);
}

class Db_Adapter_Mysql implements Db_Adapter
{
    private $_dbLink;   //数据库连接字符串标示

    public function connect($config)
    {
        $host = $config['host'];
        $port = $config['port'];
        $user = $config['user'];
        $pass = $config['pass'];
        $database = $config['database'];

        if($this->_dbLink = @mysqli_connect($host,$user,$pass,$database,$port)){
            if(@mysqli_select_db($this->_dbLink,$database)){
                return $this->_dbLink;
            }
        }

        throw new Exception(@mysqli_error($this->_dbLink));
    }

    public function query($query, $handle)
    {
        if($resource = @mysqli_query($query,$handle)){
            return $resource;
        }
    }

}

/*
 * SQLite 数据库的操作类
 * */
class Db_Adapter_sqllite implements Db_Adapter
{
    private $_dbLink;

    public function connect($config)
    {
        if($this->_dbLink = sqllite_open($config->file,0666)){
            return $this->_dbLink;
        }

        throw new Exception($error);
    }

    public function query($query, $handle)
    {
        if($resource = @sqlite_query($query,$handle)){
            return $resource;
        }
    }
}


//$a = new Db_Adapter_Mysql();
//$c = $a->connect(array('host'=>'localhost','user'=>'root','pass'=>'root','database'=>'test','port'=>3306));
//$res = $c->query('select * from user');
//$res = $res->fetch_all();
//var_dump($res);






























