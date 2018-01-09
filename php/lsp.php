<?php
/**
 * LSP：子类型必须能够替换掉它们的父类型，并出现在父类能够出现的任何地方
 */

# 缓存实现抽象类
abstract class Cache
{
    public abstract function set($key,$value,$expire = 60);

    public abstract function get($key);

    public abstract function del($key);

    public abstract function delAll();

    public abstract function has($key);
}

# 如果现在要求实现文件 、 memcache、accelerator 等各种机制下的缓存，只需要继承这个抽象类并实现其抽象方法即可











