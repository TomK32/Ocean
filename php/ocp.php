<?php
/*
 * 开放-封闭原则
 * */

interface process{
    public function process();
}

//实现播放器的编码功能
class playerencode implements process
{
    public function process()
    {
        echo "encode",PHP_EOL;
    }
}

class playeroutput implements process
{
    public function process()
    {
        echo "output",PHP_EOL;
    }
}

/*
 * 对于播放器的各种功能，这里时开放的，只要你遵守约定，实现了process接口，就能给播放器添加新的功能模块。这里只要实现解码和输出模块，还可以依据需求，加入更多的模块。
 * */

/*
 * 播放器的 调度管理器
 * 播放器一旦接到通知（可以时外部单击行为，也可以时内部的notify行为），将回调实际的线程处理
 * */
class playProcess
{
    private $message = null;
    public function __construct()
    {

    }

    public function callback(event $event)
    {
        $this->message = $event->click();
        if($this->message instanceof process)
        {
            $this->message->process();
        }
    }
}

/*
 * 播放器的事件处理逻辑
 * 具体的产品出来了，在这里定义一个mp4类，这个类是相对封闭的，其中定义事件的处理逻辑
 * */

class mp4
{
    public function work()
    {
        $playProcess = new playProcess();
        $playProcess->callback(new event('encode'));
        $playProcess->callback(new event('output'));
    }
}


/*
 * 最后为事件分拣的处理类，此类负责对事件进行分拣，判断用户或内部行为，以产生正确的’线程',供播放器内置的线程管理器调度
 * */

class event
{
    private $m;
    public function __construct($me)
    {
        $this->m = $me;
    }

    public function click()
    {
        switch($this->m){
            case 'encode':
                return new playerencode();
                break;
            case 'output':
                return new playeroutput();
                break;
        }
    }
}

$mp4 = new mp4();

$mp4->work();



























