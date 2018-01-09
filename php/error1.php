<?php
function customError($errno,$errstr,$errfile,$errline)
{
    //自定义错误处理时，手动抛出异常
    throw new Exception($errno.' | '.$errstr);
}

set_error_handler('customError',E_ALL|E_STRICT);

try
{
    $a = 5/0;
}
catch (Exception $e)
{
    echo '错误信息:',$e->getMessage();
}

// 错误信息:2 | Division by zero