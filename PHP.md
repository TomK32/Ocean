
**1.1.1 对象的形**
    
    class person{
        public $name;
        public $gender;
        public function say(){
            echo $this->name,'is ',$this->gender;
        }
    }
    
    $student = new person();
    $student->name = 'king';
    $student->gender = 'male';
    $student->say();
    
    $teacher = new person();
    $teacher->name = 'king1';
    $teacher->gender = 'male1';
    $teacher->say();
    
    //echo $str = serialize($student);
    //file_put_contents('store.txt',$str);
    
    echo $str = file_get_contents('store.txt');
    $res = unserialize($str);
    $student->say();
    
**1.1.2 对象的本**

    _PHP源码中对变量的定义_
    
    #zend/zend.h
    typedef union _zvalue_value{
        long lval;/* long value */
        double dval; /* double value */
        struct {
            char *val;
            int len;
        } str;
        HashTable *ht; /* hash table vlaue */
        zend_object_value obj;
    }zvalue_value; 
    
    _对象在ZEND（PHP底层引擎，类似Java的JVM)中定义_
    
     #zend/zend.h
     typedef struct _zend_object {
        zend_class_entry *ce;       //
     }
    
    
    
    