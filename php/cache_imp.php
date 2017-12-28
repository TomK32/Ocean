<?php
/**
 * 由于 PHP 是弱类型语言，且强调灵活，所以并不推荐大规模使用接口，而是仅在部分内核代码中使用接口
 * 接口作为一种规范和契约存在，作为规范，接口应该保证可用性；作为契约，接口应该保证可控性。
 * 接口只是一个声明，一旦使用interface关键字，就应该实现它。可以由程序员实现（外部接口），也可以由系统实现（内部接口）。接口本身什么都不做，但使它可以告诉我们它能做什么。
 * php中的接口存在两个不足，一是没有契约限制，而是缺少足够多的内部接口
 */

interface cache{
    # 缓存管理，项目经理定义接口，技术人员负责实现
    const maxKey = 1000;                //最大缓存量
    public function getc($key);         //获取缓存
    public function setc($key,$value);  //设置缓存
    public function flush();            //清空缓存
}

/*
 * php5对面向对象的特性做了许多增强，其中就有一个spl（标准php库）的尝试。spl中实现了一些接口，其中最主要的就是Iterator迭代器接口，通过实现这个接口，就能使对象能够用于foreach结构，从而在使用形式上比较统一
 * */

# Iterator 接口的原型如下

/*

* current()
* key()
* next()
* rewind()
* valid()

 * */

trait Hello{
    public function sayHello(){
        echo 'Hello ';
    }
}

trait World{
    public function sayWorld(){
        echo 'World';
    }
}

class demo{
    use Hello,World;
    public function say(){
        echo '!';
    }
}

$o = new demo();
$o->sayHello();
$o->sayWorld();
$o->say();


