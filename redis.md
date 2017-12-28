
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
                  
# 列表
    - 列表（list）类型是用来存储多个有序的字符串。可以充当栈和队列的角色 
    
    1.命令
        添加          rpush lpush linsert
        查            lrange lindex len
        删除          lpop rpop lrem ltrim
        修改          lset
        阻塞操作       blpop brpop              
        
        rpush key value [value ...]     # 从右向左插入
        lrange key 0 -1                 # 从左到右获取列表的所有元素
        
        lpush key value [value ...]     # 从左边插入元素
        
        linsert key before|after pivot value    # 在pivot元素前/后插入值
        
        lrange key start end            # 获取指定范围内的元素
        
        lindex key index                # 获取指定索引下标的元素
        
        llen key                        # 获取列表长度
        
        lpop key                        # 从左侧弹出元素
        rpop key                        # 从右侧弹出元素
        
        lrem key count value            # 删除等于 value 的元素进行删除
            - count > 0     # 从左到右，删除最多count个元素
            - count < 0     # 从右到左，删除最多count绝对值个元素
            - count = 0     # 删除所有
        
        blpop key [key ...] timeout
        brpop key [key ...] timeout
            - blpop brpop 是 lpop 和 rpop 的阻塞版本，它们除了弹出方向不同，使用方法基本相同
            - 如果 timeout为0 ，客户端会一直阻塞下去
            
    2. 内部编码
        ziplist（压缩列表） ： 当元素个数较少且没有大元素时，内部编码为ziplist（3.2提供了quicklist内部编码）
        linkedlist（链表） ： 当元素个数超过512个，内部编码变为linkedlist
                
    3. 使用场景
        - 消息队列
            redis的lpush + brpop 命令组合即可实现阻塞队列，生产者客户端使用 lrpush 从列表左侧插入元素，多个消费客户端使用brpop命令阻塞式的抢列表队尾的元素，多个客户端保证了消费的负载均衡和高可用性
            
        - 文章列表
            每个用户有属于自己的文章列表，现需要分页展示文章列表。此时可以考虑使用队列，因为队列不但时有序的，同时支持按照索引范围获取元素 
            
            每篇文章使用哈希结构存储，例如每篇文章有 3 个属性 title，timestamp，content
                hmset article:1 title xxx timestamp 147xxxxxx content xxxxx
                hmset article:2 title yyy timestamp 147xxxxxx content xxxxx
                ......
                
            向用户文章列表添加文章,user:{id}:articles 作为用户文章列表的键
                lpush user:1:articles article:1 article:2
                lpush usre:2:articles article:3 article:4
                ......
                
            分页获取用户文章列表，获取用户 id=1 的前10篇文章
                articles = lrange user:1:articles 0 9
                for article in {articles}
                    hgetall {article} 
        
        - 实际上列表的使用场景很多，在选择时可以参考一下口诀：
            lpush + lpop = Stack    # 栈
            lpush + rpop = Queue    # 队列
            lpush + ltrim = Capped Collection  # 有限集合
            lpush + brpop = Message Queue      # 消息队列   
               
# 集合
    集合（set）类型也是用来保存多个的字符串元素，但和列表类型不一样的是，集合中不允许有重复元素，并且集合中的元素是无序的，不能通过索引下标获取元素。 redis除了支持集合内的增删查改，同时还支持多个集合取交集/并集/差集
    
    1. 命令
        sadd key element [element ...]      # 添加
        srem key element [element ...]      # 删除
        
        scard key                           # 计算元素个数
        smembers key                        # 获取所有元素
        sismember key element               # 判断元素是否在集合中
        srandmember key [count]             # 随机从结合返回count个元素
        spop key                            # 从集合中随机弹出元素
        
        smembers 和 lrange hgetall 都属于比较重的命令，如果元素过多存在阻塞redis的可能性，这时可以用sscan完成
        
        sinter key [key ...]                # 求多个集合的交集
        sunion key [key ...]                # 求多个集合的并集
        sdiff key [key ...]                 # 求多个集合的差集 
        
        将交集/并集/差集的结果保存
        sinterstore destination key [key ...]       
        sunionstore destination key [key ...]      
        sdiffstore destination key [key ...]
        
    2. 内部编码
        intset(整数集合)        当元素个数较少且都为整数时
        hashtable（哈希表）     当元素个数超过512个时，当某个元素不为整数时
        
    3. 使用场景
        集合类型比较典型的使用场景时标签（tag）。例如一个用户可能对娱乐/体育比较感兴趣，另一个用户可能对历史/新闻比较感兴趣，这些兴趣点就是标签。有了这些数据就可以得到喜欢同一个标签的人，以及用户的共同喜好的标签，这些数据对于用户体验以及增强用户粘性度比较重要。例如一个电子商务的网站会对不同标签的用户做不同类型的推荐，比如对数码产品比较感兴趣的人，在各个页面或通过邮件的形式给他们推荐最新的数码产品，通常会为网站带来更多的利益。
        
        给用户添加标签
            sadd user:1:tags tag1 tag2 tag5
            sadd usre:2:tags tag2 tag3 tag5
                
        给标签添加用户
            sadd tag1:users user:1 user:3
            sadd tag2:users user:1 user:2 user:3
        
            注：用户和标签的关系维护应该在一个事务内执行，防止部分命令失败造成的数据不一致
        
        删除用户下的标签
            srem user:1:tags tag1 tag5
        
        删除标签下的用户
            srem tag1:users user:1
            srem tag5:users user:1  
            注：上面的两步操作尽量放在一个事务执行
            
        计算用户共同感兴趣的标签
            sinter user:1:tags usre:2:tags  
            
        其他应用场景    
            sadd = Tagging（标签）
            spop/srandmember = Random item（生成随机数，比如抽奖）
            sadd + sinter = Social Graph（社交需求）        
            
# 有序集合
    有序集合中的元素可以排序。但是它和列表使用索引下标和排序依据不同的是，它给每个元素设置一个分数 score 作为排序的依据。集合中的元素不能重复，但score可以重复
    
    数据结构        允许重复元素          是否有序            有序实现方式          应用场景
    列表              是                   是               索引下标            时间轴/消息队列等
    集合              否                   否               无                 标签/社交等
    有序集合           否                   是               分值               排行榜系统/社交等
    
    1. 命令
        zadd key score member [score member ...]
        
        nx      # member 必须不存在，用于添加
        xx      # member 必须存在，用于更新
        ch      # 返回此次操作后，有序集合元素和分数发生变化的个数
        incr    # 对score做增加，相当于后面介绍的zincrby
        
        zcard key               # 计算成员个数
        
        zscore key member       # 计算某个成员的分数    
        
        zrank key member        # 分数从低到高返回排名
        zrevrank key member     # 分数从高到低返回排名
        
        zrem key member [member ...]
        
        zincrby key increment member                # 增加成员的分数
        
        zrange key start end [withscores]           # 从低到高返回指定排名范围的成员
        zrevrange key start end [withscores]        # 从高到低返回指定排名范围的成员
        
        zrangebyscore key min max [withscores]      # 返回指定分数范围的成员
        zrevrangebyscore key max min [withscores]   # 同上
        
        zcount user:ranking min max                 # 返回指定分数范围成员个数
            
        zremrangebyrank key start end               # 删除指定排名内的升序元素
        zremrangebyscore key min max                # 删除指定分数范围的成员
        
        zinterstore destination numkeys key [key ...] [weights weight [wieight...]] [aggregate sum|min|max]
            - destination                   # 交集的计算结果保存到这个键
            - numkeys                       # 需要做交集计算键的个数
            - key[key...]                   # 需要做交集计算的键
            - weights weight[weight ...]    # 每个键的权重，在做交集时，每个键中的每个member会将自己分数乘以这个权重，每个键的权重默认是1
            - aggregate sum|min|max         # 计算成员交集后，分支可以按照 sum min max 做汇总，默认值是sum
        
        zunionstore destination numkeys key [key ...] [weights weight [weight ...]] [aggregate sum|min|max]
        
    2. 内部编码
        ziplist
        skiplist    
    
    3. 使用场景
        有序集合典型的使用场景就是排行榜系统。例如视频网站需要对用户上传的视频做排行榜，榜单的维度可能是多个方面的：按照时间/播放量/获得的赞数等
        
        添加用户赞数（比如用户 mike 上传了一个视频，并获得了3个赞）
            zadd user:ranking mike 3
            
        如果之后再获得一个赞，可以使用 zincrby
            zincrby user:ranking mike 1
        
        取消用户赞数（由于各种原因需要将用户删除，可以使用zrem）
            zrem user:ranking mike        
        
        展示获取赞数最多的十个用户
            zrevrangebyrank user:ranking 0 9
        
        展示用户信息及分数
            hgetall user:info:tom
            zscore user:ranking mike
            zrank user:ranking mike     
                    
# 键管理

    ## 单个键管理        
        
        rename key newkey       # 重命名
        
        renamenx key newkey     # 只有再newkey不存在时才成功    
        
        注：由于重命名键期间会执行del命令删除旧的键，如果键对应的值比较大，会存在阻塞redis的可能性
        
        randomkey               # 随机返回一个键
        
        expire key seconds      # 键再seconds秒后过期
        expire key timestamp    # 键在秒级timestamp后过期
        ttl key                 # 键剩余的过期时间
        persist key             # 清除键的过期时间
        
        对于字符串类型键，set命令会去掉过期时间
        redis 不支持二级数据结构（例如哈希/列表）内部元素的过期功能
        setex 命令作为set + expire 的组合，不但是原子执行，同时减少了一次网络通讯的时间
        
        ### 迁移键
            把部分数据有一个redis迁移到另一个redis（生产环境到测试环境）
            
            move key db     # 在redis内部迁移数据
            
            dump key restore key ttl value
                dump + restore 可以实现在不同的redis示例之间进行数据迁移的功能，整个迁移过程分为两步
                - 在源 redis 上，dump命令会将键值序列化，格式采用的是RDB格式
                - 在目标 redis 上，restore命令将上面序列化的值进行复原，其中ttl参数代表过期时间，为0代表没有过期时间
                
                -伪代码
                    Redis sourceRedis = new Redis('sourceMachine',6379);
                    Redis targetRedis = new Redis('targetMaching',6379);
                    targetRedis.restore('hello',0,sourceRedis.dump(key));
                    
            migrate host port key|"" destination-db timeout [copy] [replace] [keys [key [key...]]        
            
# scan
    
    String key = 'myset';
    //定义pattern
    String pattern = 'old:user*';
    //每次游标从0开始
    String sursor = 0; 
    while(true){
        //获取扫描结果
        ScanResult ScanResult = redis.sscan(key,cursor,pattern);
        List elements = scanResult.getResult();
        if(elements != null && elements.size() > 0){
            //批量删除
            redis.srem(key,elements);
        }
        //获取新的游标
        cursor = scanResult.getStringCursor();
        //如果游标为0表示遍历结束
        if('0'.equal(corsor)){
            break;
        }
    }
    
    
# Jedis
    
    Jedis jedis = new Jedis('127.0.0.1',6379);
    jedis.set('hello','world');
    String value = jedis.get('hello');
    
    String setResult = jedis.set('hello','world');
    String getResult = jedis.get('hello');
    System.out.println(setResult);
    SYstem.out.println(getResult);
    
    --
    
    Jeids jedis = null;
    try{
        jedis = new Jedis('127.0.0.1',6379);
        jedis.get('hello');
    }catch (Exception e){
        logger.error(e.getMessage(),e);
    }finally{
        if(jedis != null){
            jedis.close();
        }
    }
    
    -- 
    
    jedis.set('hello','world');
    jedis.get('hello');
    jedis.incr('counter');
    
    jedis.hset('myhash','f1','v1');
    jedis.hset('myhash','f2','v2');
    jedis.hgetAll('myhash')
    
    jedis.rpush('mylist',1);
    jedis.rpush('mylist',2);
    jedis.rpush('mylist',3);
    jedis.lrange('mylist',0,-1);
    
    jedis.sadd('myset','a');
    jedis.sadd('myset','b');
    jedis.sadd('myset','a');
    jedis.smembers('myset');
    
    jedis.zadd('myzset',99,'tom'); 
    jedis.zadd('myzset',98,'tom1'); 
    jedis.zadd('myzset',97,'tom2'); 
    jedis.zrangeWithScores('myzset',0,-1);
    
## Jedis 连接池的用法
    所有Jedis对象预先放在池子中（JedisPool），每次要连接redis，只需要在池子中借，用完了再归还给池子
               
    客户端连接人redis使用的是tcp协议，直连的方式每次需要建立tcp连接，而连接池的方式是可以预先初始化好jedis连接，所以每次只需要从Jedis连接池中借用即可，而借用和归还是在本地进行的，只有少量的并发同步开销，远远小于新建tcp连接的开销。另外直连的方式无法限制jedis对象的个数，在极端情况下可能会造成连接泄露，而连接池的形式可以有效的保护可控制资源的使用。但是直连的方式也不是一无是处。
    
    Jedis 提供了 JedisPool 这个类作为对Jedis的连接池，同时使用了Apache的通用对象池工具common-pool作为资源的管理工具，下面是使用JedisPool操作Redis的代码示例：
    
    -- Jedis连接池（通常 JedisPool是单例的）
        GenericObjectPollConfig poolConfig = new GenericObjectPoolConfig();
        JedisPool jedispool = new JedisPool(poolConfig,'127.0.0.1',6379);
        
        Jedis jedis = null;
        
        try{
            jedis = jedisPool.getResource();
            jedis.get('hello');
        }catch(Exception e){
            logger.error(e.getMessage(),e);
        }finally{
            if(jedis != null){
                //如果使用JedisPool，close操作不是关闭连接，代表归还连接
                jedis.close();
            }
        }
        
    -- jeids 的close（） 实现：
        public void close(){
            if(dataSource != null){
                if(client.isBroken()){
                    this.dataSouce.returnBrokenResource(this);
                }else{
                    this.dataSouce.returnResource(this);
                }
            }else{
                client.close();
            }
        }           
    
# Pipeline

    public void model(List<String> keys){
        Jedis jedis = new Jedis('127.0.0.1');
        Pipeline pipeline = jedis.pipelined();
        for(String key : keys){
            pipeline.del(key);
        }
        pipeline.sync();
    }          
       
    --
    
    Jedis jedis = new Jedis('127.0.0.1');
    Pipeline pipeline = jedis.pipeline();
    pipeline.set('hello','world');
    pipeline.incr('counter');
    List<Object> resultList = pipeline.syncAndReturnAll();
    for(Object object : resultList){
        System.out.println(object);
    }   
        
# Jedis 的 lua 脚本
    
    String key = 'name';
    String script = 'return redis.call("get",KEYS[1])";
    Object result = jedis.eval(script,1,key);
    System.out.println(result);
    
    String key = 'nam';
    Object result = jedis.evalsha(scriptSha,1,key);
    System.out.println(result);
        
        
#  redis-py

    pip install redis
    
    import redis
    client = redis.StrictRedis(host='127.0.0.1',port = 6379)
    key = 'name'
    setResult = client.set(key,'king')
    print setResult
    value = client.get(key)
    print 'key:' + key + ', value:' + value;
    
    client.set('name','king')
    client.get('name')
    
    client.incr('num')
    
    client.hset('hash','f1','v1')
    client.hset('hash','f2','v2')
    client.hgetall('hash')
    
    client.rpush('list',1)
    client.rpush('list',2)
    client.rpush('list',3)
    client.lrange('list',0,-1)
    
    client.sadd('set','a')
    client.sadd('set','b')
    client.sadd('set','a')
    client.smembers('set')
    
    client.zadd('set','99','king1')
    client.zadd('set','991','king2')
    client.zadd('set','992','king3')
    client.zrange('set',0,-1,withscores=True)
    
# redis-py 中的 Pipeline
    
    import redis
    client = redis.StrictRedis(host='127.0.0.1',port=6379)
    
    pipeline = client.pileline(transaction=False)
    
    pipeline.set('name','king')
    pipeline.incr('num')
    
    result = pipeline.execute() 
    
    --
    
    import redis
    def mdel(keys):
        client = redis.StrictRedis(host='127.0.0.1',port = 6379)
        pipeline = client.pipeline(transaction=False)
        for key in keys:
            print pipeline.delete(key)
        return pipeline.execute();
        
           
           
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        