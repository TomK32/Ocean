<?php
/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2017-12-28
 * Time: 9:31
 */
//继承拥有比组合更少的代码量
class car
{
    public function addoil(){
        echo "add oil \r\n";
    }
}

//继承只需要继承父类即可
class bmw extends car{

}

//组合代码量更大
class benz{
    public $car;
    public function __construct()
    {
        $this->car = new car;
    }

    public function addOil(){
        $this->car->addoil();
    }

}

$bmw = new bmw;
$bmw->addoil();

$benz = new benz();
$benz->addOil();

/*

继承破坏封装性
继承是紧耦合的
继承扩展复杂
不恰当的使用继承可能违反现实世界中的逻辑

精心设计专门用于被继承的类，继承树的抽象层应该比较稳定，一般不要多余三层
对于不是专门用于继承的类，禁止其被继承，也就是使用final修饰符，使用final修饰符既可以防止重要方法被非法覆写，又能给编辑器寻找优化的机会。
优先考虑用组合关系提高代码的可重用性
子类是一种特殊的类型，而不只是父类的一个角色
子类扩展，而不是覆盖或者使父类的功能失效
底层代码多用组合，顶层/业务层代码多用继承。底层用组合可以提高效率，避免对象臃肿。顶层代码用继承可以提高灵活性，让业务使用更方便

多重继承里一个类可以同时继承多个类，组合两个父类的功能。c++里就使用的这种模型来增强继承的灵活性的，但是多重继承过于灵活，并且会带来菱形问题，故为其使用带来了不少困难，模型变得复杂起来，因此在大多数语言中，都放弃了继承这一模型。

PHP5.4 引入的新的语法结构Traits 就是一种很好的解决方案。Traits的思想来源于C++和Ruby里的Mixin以及Scala里的Traits，可以方便我们实现对象的扩展，是除extend，implements外的另外一种扩展对象的方式。Traits即可以使单继承模式的语言获得多重继承的灵活，又可以避免多重继承带来的种种问题


 * */
