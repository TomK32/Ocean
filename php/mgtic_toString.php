<?php
/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2017-12-28
 * Time: 8:48
 */


class magic_toString{
    public $user = 1;
    private $pwd = 2;
    public function __toString(){
        return "user : {$this->user}, pass : {$this->pwd}";
    }
}

$a = new magic_toString();
echo $a;

echo PHP_EOL;
print_r($a);

/* echo 本来可以打印一个对象，但是php对其做了限制，只有实现toString后才允许使用*/
/*ZEND_VM_HANDLER(40,ZEND_ECHO,CONST|TMP|VAR|CV,ANY)
{
    zend_op *opline = EX(opline);
    zend_free_op free_op1;
    zval z_copy;
    zval *z = GET_OP1_ZVAL_PTR(BP_VAR_R);
    //此处的代码预留了把对象转换为字符串的接口
    if(OP1_TYPE != IS_CONST && Z_OBJ_HT_P(z)->get_method != NULL && zend_std_cast_object_tostring(z,&z_copy,IS_STRING TSRMLS_CC) == SUCCESS){
        zend_print_variable(&z_copy);
        zval_dtor(&z_copy);
    }else{
        zend_print_variable(z);
    }
    ZFREE_OP1();
    ZEND_VM_NEXT_OPCODE();
}*/

/*

Account.java

import org.apache.commons.lang3.builder.ToStringBuilder;

public class Account{
    private String user;
    private String pwd;

    public Account(){
        System.out.println('构造函数');
    }

    public Acccount(String user,String pwd){
        System.out.println('重载构造函数');
        System.out.println(user + '----' + pwd);
    }

    public void say(String user){
        System.out.println('用户是:' + user);
    }

    public void say(String user,String pwd){
        System.out.println('用户:' + user);
        System.out.println('密码：' + pwd);
    }

    public String getUser(){
        return user;
    }

    public void setUser(String user){
        this.user = user;
    }

    public String getPwd(){
        return pwd;
    }

    public void setPwd(String pwd){

    }

    @Override
    public String toString(){
        return ToStringBuilder.reflectionToString(this);
    }

    public static void main(String...){
        Account account->new Account();
        account.setUser('aaa');
        account.setPwd('123123');
        account.say('bbb');
        account.say('ccc',111222);
        System.out.println(account);
    }

}


可以看出，java的构造方法比php好用，php由于有了__set __get 这一对魔术方法，使得动态增对象的属性字段变得很方便，而对java来说，要实现类似的效果，就不得不借助反射API或直接修改编译后字节码的方式来实现。这体现了动态语言的优势，简单，灵活

*/

