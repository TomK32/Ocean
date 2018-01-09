<?php

//厨师类 ，命令接受者与执行者
class cook
{
    public function meal()
    {
        echo '番茄炒鸡蛋',PHP_EOL;
    }

    public function drink()
    {
        echo '紫菜蛋花汤',PHP_EOL;
    }

    public function ok()
    {
        echo '完毕',PHP_EOL;
    }
}

//命令接口
interface Command{
    public function execute();
}

//模拟服务员与厨师的过程
class MealCommand implements Command{
    private $cook;
    public function __construct(cook $cook)
    {
        $this->cook = $cook;
    }

    public function execute()
    {
        //把消息传给厨师，让厨师做饭，下同
        $this->cook->meal();
    }
}

class DrinkCommand implements Command
{
    private $cook;
    public function __construct(cook $cook)
    {
        $this->cook = $cook;
    }

    public function execute()
    {
        $this->cook->drink();
    }
}

//模拟顾客与服务员的过程
class cookControl
{
    private $mealcommand;
    private $drinkcommand;

    //把命令发送者绑定到命令接收器上面来
    public function addCommand(Command $mealcommand,Command $drinkcommand)
    {
        $this->mealcommand = $mealcommand;
        $this->drinkcommand = $drinkcommand;
    }

    public function callmel()
    {
        $this->mealcommand->execute();
    }

    public function calldrink()
    {
        $this->drinkcommand->execute();
    }
}

//实现命令模式
$control = new cookControl();

$cook = new cook;
$mealcommand = new MealCommand($cook);
$drinkcommand = new DrinkCommand($cook);
$control->addCommand($mealcommand,$drinkcommand);
$control->callmel();
$control->calldrink();






























