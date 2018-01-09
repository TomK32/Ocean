<?php

/**
 * Class leaveModel
 * 实际留言的过程可能会更负责，可能还包括一系列准备操作以及log处理，所以应该定义一个类负责数据的逻辑处理
 */
class leaveModel
{
    public function write(gbookModel $gb,$data)
    {
        $book = $gb->getBookPath();
        $gb->write($data);
        //记录日志
    }
}
