<?php
/**
 * 反射可以用于文档生成，因此可以用它对文件里的类进行扫描，逐个生成描述文档
 * 既然反射可以探知类的内部结构，那么是不是可以用它做hook实现插件功能呢？或者使做动态代理呢？ 例子：proxy.php
 */

class person{
    public $name;
    public $gender;
    public function say(){
        echo $this->name,"\tis ",$this->gender,"\r\n";
    }

    public function __set($name,$value)
    {
        echo "Setting $name to $value \r\n";
        $this->$name = $value;
    }

    public function __get($name){
        if(!isset($this->$name)){
            echo '未设置';
            $this->$name = 'setting...';
        }
        return $this->$name;
    }
}

//$student = new person();
//$student->name = 'Tom';
//$student->gender = 'mail';
//$student->age = 24;
//
//// 获取对象属性列表
//$reflect = new ReflectionObject($student);
//$props = $reflect->getProperties();
//foreach($props as $prop)
//{
//    print $prop->getName() . "\n";
//}
//
////获取对象方法列表
//$m = $reflect->getMethods();
//foreach($m as $prop)
//{
//    print $prop->getName() . "\n";
//}
//
////返回对象属性的关联数组
//var_dump(get_object_vars($student));
////类属性
//var_dump(get_class_vars(get_class($student)));
////返回由类的方法名组成的数组
//var_dump(get_class_methods(get_class($student)));
//
////获取对象属性列表所属的类
//echo get_class($student);


$obj = new ReflectionClass('person');
$className = $obj->getName();
$Methods = $Properties = array();
foreach($obj->getProperties() as $v)
{
    $Properties[$v->getName()] = $v;
}

foreach($obj->getMethods() as $v)
{
    $Methods[$v->getName()] = $v;
}

echo "class {$className}\n{\n";
is_array($Properties) && ksort($Properties);

foreach($Properties as $k => $v)
{
    echo "\t";
    echo $v->isPublic() ? 'public' : '';
    echo $v->isPrivate() ? 'private' : '';
    echo $v->isProtected() ? 'protected' : '';
    echo $v->isStatic() ? 'static' : '';
    echo "\t{$k}\n";
}

echo "\n";
if(is_array($Methods)) ksort($Methods);
foreach($Methods as $k => $v)
{
    echo "\tfunction {$k}(){}\n";
}

echo "}\n";













