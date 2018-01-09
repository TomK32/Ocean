<?php
/**
 * 依赖倒置原则
 * 将依赖关系倒置为依赖接口
 * 上层模块不应该依赖于下层模块，它们共同依赖于一个抽象（父类不能依赖子类，他们都要依赖抽象类）
 * 抽象不能依赖于具体，具体应该依赖于抽象
 */

interface employee
{
    public function working();
}

class teacher implements employee
{
    public function working()
    {
        echo 'teaching...';
    }
}

class coder implements employee
{
    public function working()
    {
        echo 'coding...';
    }
}

class workA
{
    public function work()
    {
        $teacher = new teacher;
        $teacher->working();
    }
}

class workB
{
    private $e;
    public function set(employee $e)
    {
        $this->e = $e;
    }

    public function work()
    {
        $this->e->working();
    }
}
//
//$a = new workA();
//$a->work();

$b = new workB();
$b->set(new teacher());
$b->work();

/*
 * classA 中，work 方法依赖于teacher实现
 * classB 中，work 转而依赖于抽象，这样可以把需要的对象通过参数传入
 * 上述代码通过接口，实现了一定程度的解耦，但仍然是有限的。
 * 不仅是接口，使用工厂等也能实现一定程度的解耦和依赖倒置
 *
 * workB 中，teacher实例通过setter方法传入中，从而实现了工厂模式。由于这样的实现仍然是硬编码的，为了实现代码的进步一扩展，把这个依赖关系写在配置文件里，指明classB 需要一个teacher对象，专门由一个程序检测配置是否正确（如所依赖的类文件是否存在）以及加载配置中所依赖的实现，这个检测程序，就是IOC容器
 *
 * */
























