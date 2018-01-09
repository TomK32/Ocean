<?php
class shutDown
{
    public function stop()
    {
        if(error_get_last())
        {
            print_r(error_get_last());
        }
        die('Stop.');
    }
}

register_shutdown_function(array(new shutDown(),'stop'));

$a = new a();   //将因为致命错误而失败
echo '必须终止';

