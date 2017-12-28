<?php
/**
 * 接口通常用来作为类之间的一个协议，接口是抽象类的变体，接口中所有的方法都是抽象的，没有一个程序体。
 * 接口除了可以包含方法外，还能包含常量
 */

interface mobile
{
    public function run();
}

class plain implements mobile
{
    public function run()
    {
        echo 'im plain';
    }

    public function fly()
    {
        echo 'fling...';
    }
}

class car implements mobile
{
    public function run()
    {
        echo 'im car \r\n';
    }
}

class machine
{
    function demo(mobile $a)
    {
        $a->fly();              //Mobile 接口每有这个方法
    }
}

$o = new machine();
$o->demo(new plain());          // fling....
$o->demo(new car());            // 错误


/*
 * 数据库操作，缓存等
 * 不需要关心数据库是oracle还是mysql，只需要关心面向database接口进行具体业务的逻辑相关的代码，者就是面向接口编程的来历
 * */

