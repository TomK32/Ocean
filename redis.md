
# 安装
    wget http://download.redis.io/releases/redis-3.0.7.tar.gz
    tar xzf redis-3.0.7.tar.gz
    ln -s redis-3.0.7 redis      # 建立redis目录的软连接，这样做是为了不把redis目录固定在指定版本上，有利于未来版本升级
    cd redis
    make
    make install
    
    redis-cli -v
    
    redis-server --port 6380    # 用6380端口启动redis
    redis-server /etc/redis/redis.conf
    
    redis-cli -h 127.0.0.1 -p 6379
    redis-cli shutdown
    redis-cli shutdown nosave|save      # 关闭redis前，是否生成持久化文件
    
# redis 执行文件说明    
    redis-server        # 启动redis
    redis-cli           # redis 命令行客户端
    redis-benchmark     # redis 基准测试工具
    redis-check-aof     # redis AOF 持久化文件检测和修复工具
    redis-check-dump    # redis RDB 持久化文件检测和修复工具
    redis-sentinel      # 启动 redis sentinel
  
# 数据类型
    string      # 字符串
    hash        # 哈希
    list        # 列表
    set         # 集合
    zset        # 有序集合
    
# 配置文件
    port                # 端口
    logfile             # 日志文件
    dir                 # Redis 工作目录（存放持久化文件和日志文件）
    daemonize           # 是否以守护进程的方式启动redis  
    
# 全局命令
    keys *                  # 查看所有键
    dbsize                  # 键总数
    exists key              # 键是否存在
    del key key1 key2...    # 删除key  
    expire key seconds      # 键过期
    ttl key                 # 键剩余过期时间
        -1 键没设置过期时间
        -2 键不存在
    type key                # 键的数据结构类型
    object encoding name    # 查询内部编码
    
# 命令
    set key value [ex seconds] [ps milliseconds] [nx|xx]
        -- ex seconds       # 为键设置秒级过期时间
        -- px milliseconds  # 为键设置毫秒级过期时间    
        -- nx               # 键必须不存在，才可以设置成功，用于添加
        -- xx               # 键必须存在，才可以设置成功，用于更新
    setex key seconds value # 作用和选项 ex 一样
    setnx key value         # 作用和选项 nx 一样
    
    get key         # 获取值
     
    mset key val [key1 val1 ...]    # 批量设置值 
    mget key key1 ...               # 批量获取值
    
    # 计数
        incr key
        decr key 
        incrby key increment
        decrby key decrement
        incrbyfloat key incrment
    
# 不常用命令
    append key value            # 向字符串末尾追加值
    strlen key                  # 字符串长度
    getset key value            # 设置并返回原值
    setrange key offset value   # 设置指定位置的字符
    getrange key start end      # 获取部分字符串   
    
# 内部编码
    # string （redis会根据当前值的类型和长度决定使用哪种内部编码实现）
        int     # 8个字节的长整型
        dmbstr  # 小于等于39个字节的字符串
        raw     # 大于 39 个字节的字符串
        
# 典型使用场景
        
    1.缓存功能
        redis作为缓存层，mysql作为存储层，绝大部分请求的数据都是从redis中获取。
       
        UserInfo getUserInfo(long id){
            userRedisKey = "user:info:" + id;       # 定义键
            value = redis.get(userRedisKey);        # 从redis获取值
            if(value != null){
                userInfo = deserialize(value);      # 将值反序列化为UserInfo
            }else{
                userInfo = mysql.get(id);           # 从mysql中获取
                if(userInfo != null){
                    redis.setex(userRedisKey,3600,serialize(userInfo)); #将userInfo序列化，并存入redis
                }
            }
            return userInfo;
        }      
        
    2.计数
        # 用户每播放一次视频，相应的视频播放数就会自增1
        
        long incrVideoCounter(long id){
            key = "video:playCount:" + id;
            return redis.incr(key);
        }    
        
    3.共享session
        一个分布式web服务将用户的session信息（例如用户登陆信息）保存在各自的服务器中，这样会造成一个问题，出于负载均衡的考虑，分布式服务会将用户的访问均衡到不同服务器上，用户刷新一次访问可能会发现需要重新登陆。
        可以将用户的session放到redis中集中管理，只要保证redis是高可用和扩展性的，每次用户更新或者查询登录信息都直接从redis中集中获取
     
    4.限速
        # 限制用户每分钟获取验证码的频率
        
        phoneNum = '138********';
        key = "shortMsg:limit:" + phoneNum;
        isExists = redis.set(key,1,"EX 60","NX");
        if(isExists != null || redis.incr(key) <= 5){
            //通过
        }else{
            //限速
        }  
        
        # 一些网站限制一个ip地址不能在一秒钟内访问超过n次也可以采用类似的思路
                
# 哈希

    1. 命令
        
        hset key field value
        hget key field     
        hdel key field
        hlen key
        
        hmset key field1 value1 field2 value2 ...
        hmget key field1 field2 field2 ...
        
        hexists key field
        
        hkeys key           # 获取所有的keys
        hvals key           # 获取所有的值
        hgetall key         # 获取所有的键值
           
        hincrby key field       
        hincrbyfloat key field  
        
        hstrlen key field   # 计算value长度
        
    2.内部编码
        ziplist (压缩列表)        # 当field个数比较少且没有大的value时，内部编码为ziplist
        hashtable （哈希表）       # 当有value大于64字节，变为hashtable
        
    3.使用场景
        哈希类型缓存用户信息
        UserInfo getUserInfo(long id){
            // 设置key
            userRedisKey = "user:info:" + id;
            // 使用 hgetall 获取所有用户信息映射关系
            userInfoMap = redis.hgetAll(userReidsKey);
            UserInfo userInfo;
            if(userInfoMap != null){
                // 将映射关系转换为 UserInfo
                userInfo = transferMapToUserInfo(userInfoMap);
            }else{
                // 从mysql中获取用户信息
                userInfo = mysql.get(id);
                // 将userInfo变为映射关系使用 hmset 保存到 redis 中
                redis.hmset(userRedisKey,transferUserInfoToMap(userInfo);
                // 添加过期时间
                redis.expire(userRedisKey,3600);
            }
            return userInfo;
        }    
                  
               
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
