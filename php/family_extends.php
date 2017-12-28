<?php
/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2017-12-28
 * Time: 9:18
 */

class person
{
    public $name = 'king';
    public $gender;
    static $money = 10000;
    public function __construct()
    {
        echo 'this is father class',PHP_EOL;
    }

    public function say(){
        echo $this->name,"\tis",$this->gender,"\r\n";
    }
}

class family extends person{
    public $name;
    public $gender;
    public $age;
    static $money = 10000;
    public function __construct()
    {
        parent::__construct();
        echo 'this is son class',PHP_EOL;
    }

    public function say()
    {
        parent::say();
        echo $this->name,"\tis\t",$this->gender,",and is\t",$this->age,PHP_EOL;
    }

    public function cry()
    {
        echo parent::$money,PHP_EOL;
        echo '% >_< %',PHP_EOL;
        echo self::$money,PHP_EOL;
        echo '(*^__^*)';
    }
}

$poor = new family();
$poor->name = 'Lee';
$poor->gender = 'female';
$poor->age = 25;
$poor->say();
$poor->cry();









































