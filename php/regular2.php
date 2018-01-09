<?php

$a = "<p>ppp</p><!-- comment --><a href='aaa'>aaa</a><div>divs</div>";

echo strip_tags($a);
echo "\n";

//允许 <p> <a>
echo strip_tags($a,'<p><a>');


$cnt = 1000;
$testStr = '';
for($i = 0;$i < 1000;$i++){
    $testStr .= "abababcdefg";
}

$start = microtime(TRUE);
for($i = 0;$i<$cnt;$i++){
    preg_match('/^(a|b|c|d|e|f|g)+$/',$testStr);
}
echo 'waste time(s):',microtime(TRUE)-$start,PHP_EOL;

$start = microtime(TRUE);
for($i = 0;$i<$cnt;$i++) {
    preg_match('/^[a-g]+$/',$testStr);
}
echo 'waste time(s):',microtime(TRUE)-$start,PHP_EOL;
