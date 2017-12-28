<?php
/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2017-12-28
 * Time: 9:48
 */

/*
 * 多态指同一对象在运行时的具体化
 * php语言是弱类型的，实现堕胎更简单，更灵活
 * 类型转换不是多态
 * php中父类和子类看作继父和继子的关系，他们存在继承关系，但不存在血缘关系。因此子类无法向上转型为父类，从而失去了多态最典型的特征
 * 多态的本质就是if else 只不过实现的层级不同
 * */

class employee
{
    protected function working()
    {
        echo "本方法需要重载才能运行";
    }
}

class teacher extends employee
{
    public function working()
    {
        echo 'teaching';
    }
}

class coder extends employee
{
    public function working()
    {
        echo 'coding...';
    }
}

function doprint($obj)
{
    if(get_class($obj) == 'employee'){
        echo 'Error';
    }else{
        $obj->working();
    }
}

doprint(new teacher());
doprint(new coder());
doprint(new employee());



/*
C++ 中用虚函数实现多态
#include <cstdlib>
#include <iostream>

using namespace std;
class father{
    public;
    father():age(30){cout << "父类构造方法,年龄"<<age<<"\n";}
    ~father(){cout<<"父类析构"<<"\n";}
    void eat(){cout<<"父类吃饭吃三斤"<<"\n";}
    virtual void run(){cout<<"父类跑1000米"<<"\n";}//虚函数
    protected:
    int age;
}

class son:public father
{
    public:
        son(){cout<<"子类构造法"<<"\n";}
        ~son(){cout<<"子类析构"<<"\n";}
        void eat(){cout<<"son eat 1kg"<<"\n";}
        void run(){cout<<"son run 100 m"<<"\n";}
        void cry(){cout<<"cring..."<<"\n";}
};

int main(int argc,char *argv[])
{
    father *pf = new son;
    pf->eat();
    pf->run();
    delete pf;
    system('PAUSE');
    return EXIT_SUCCESS;
}

上面的方法首先定义个父类，然后定义个子类，这个子类继承父类的一些方法并且有自己的方法。通过father *pf = new son;语句创建一个派生类（子类）对象，并且把该派生类对象赋给基类（父类）指针，然后用该指针访问父类中的eat和run方法。

由于父类中run方法加了virtual关键字，表示该函数有多种形态，可能被多个对象所拥有。多个对象在调用统一名字的函数时会产生不同的效果

由于php时弱类型的，并且也没有对象转型机制，所以不能像c++或者java那样实现father $pf = new son; 把派生类对象赋给基类对象，然后再调用函数时动态改变其指向。在php例子中，对象都时确定的，是不同类的对象

 * */

# 通过接口实现多态

interface employee1{
    public function working();
}

class teacher1 implements employee1{
    public function working(){
        echo 'teaching...';
    }
}

class coder1 implements employee1{
    public function working()
    {
        echo 'coding...';
    }
}

function doprint1(employee1 $i)
{
    $i->working();
}

$a1 = new teacher1();
$b1 = new coder1();
doprint1($a1);
doprint1($b1);















