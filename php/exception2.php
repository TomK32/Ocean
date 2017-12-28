<?php
/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2017-12-28
 * Time: 11:55
 */

class emailException extends exception
{

}

class pwdException extends exception
{
    function __toString()
    {
        return "<div class='error'>
                Exception{$this->getCode()}:{$this->getMessage()} 
                if File:{$this->getFile()} on line:{$this->getLine()}</div>";
        //改写抛出异常结果
    }
}

function reg($reginfo = null)
{
    if(empty($reginfo) || !isset($reginfo)){
        throw new Exception('参数非法');
    }

    if(empty($reginfo['email'])){
        throw new emailException('邮件为空');
    }

    if($reginfo['pwd'] != $reginfo['repwd']){
        throw new pwdException('两次密码不一致');
    }
    echo '注册成功';
}

try{
    reg(array('email'=>'123@qq.com','pwd'=>123123,'repwd'=>123123));
}catch (emailException $ee){
    echo $ee->getMessage();
}catch (pwdException $ep){
    echo $ep;
    echo PHP_EOL,'特殊处理';
}catch(Exception $e){
    echo $e->getTraceAsString();
    echo PHP_EOL,'其他情况，统一处理';
}



























