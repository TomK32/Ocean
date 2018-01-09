<?php


function customerError($errno,$errstr,$errfile,$errline)
{
    echo "错误代码: $errno",PHP_EOL;
    echo "错误信息: $errstr",PHP_EOL;
    echo "文件: $errfile",PHP_EOL;
    echo "错误所在代码行: $errline",PHP_EOL;
    echo "PHP版本 ",PHP_VERSION;
}

set_error_handler('customerError',E_ALL|E_STRICT);
$a = array('o'=>2,4,6,8);
echo $a[o];