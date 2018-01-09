<?php

class gbookModel
{
    private $bookPath;      // 留言本文件
    private $data;          // 留言数据

    public function setBookPath($bookPath)
    {
        $this->bookPath = $bookPath;
    }

    public function getBookPath()
    {
        return $this->bookPath;
    }

    public function open()
    {

    }

    public function close()
    {

    }

    public function read()
    {
        return file_get_contents($this->bookPath);
    }

    //写入留言
    public function write($data)
    {
        $this->data = self::safe($data)->name."&".self::safe($data)->email."\r\n said : \r\n" . self::safe($data)->content;
        return file_put_contents($this->bookPath,$this->data,FILE_APPEND);
    }

    public static function safe($data)
    {
        $reflect = new ReflectionObject($data);
        $props = $reflect->getProperties();

        $messagebox = new stdClass();
        foreach($props as $prop){
            $ivar = $prop->getName();
            $messagebox->$ivar = trim($prop->getValue($data));
        }
        return $messagebox;
    }

    public function delete()
    {
        file_put_contents($this->bookPath,'its empty now');
    }

}






























