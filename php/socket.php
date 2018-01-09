<?php

$sock = fsockopen('192.168.1.170',8088,$errno,$errstr);

if(!$sock){
    echo "$errstr($errno)<br/>\n";
}else{
    socket_set_blocking($sock,false);
    fwrite($sock,"send data...\r\n");
    fwrite($sock,"end\r\n");
    while(!feof($sock)){
        echo fread($sock,128);
        flush();
        ob_flush();
        sleep(1);
    }
    fclose($sock);
}