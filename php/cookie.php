<?php
/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2018-01-08
 * Time: 17:55
 */

# cookie 是在远程浏览器端存储数据来识别用户的机制。
# setcookie($name,$value,$expire,$path,$domain,$secure,$httponly);

?>

<script>
    // cookie 防止刷票
    function justByOnes()
    {
        var wid = $('#articleId').val();
        if(cookie('done') == wid){
            alert("已投票");
            return false;
        }else{
            cookie('done',wid);
            return;
        }
    }

    window.localStorage.name = 'king';
    window.localStorage['a'] = 'aaa';
    console.log(window.localStorage['a']);
    console.log(window.localStorage.getItem('name'));

    var showStorage = function(){
        var storage = window.localStorage;
        for(var i = 0; i < storage.length;i++){
            console.log(storage.key(i) + ":" + storage.getItem(storage.key(i)) + "<br>");
        }
    };
    showStorage();

</script>

