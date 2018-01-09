<?php


// 1. cookie 运行在客户端，session运行在服务器端，对吗？
# 不完全正确，cookie 是运行在客户端，由客户端进行管理；session虽然是运行在服务器端，但是sessionID作为一个cookie是存储在客户端的

// 2. 浏览器禁用cookie，cookie就不能用了，但session不会受浏览器影响，对码？
# 错，浏览器禁止cookie，cookie确实不能用了，session会受浏览器影响。在登陆一个网站后，清空浏览器的cookie和隐私数据，单击后台的连接，就会因为丢失cookie而退出。当然，有办法通过url传递session

// 3. 关闭浏览器后，cookie和session都消失了，对吗？
# 错。存储在内存中的cookie确实会跟着浏览器的关闭而消失，但存储在硬盘上的不会。更顽固的是FLASH Cookie，夸张的说只有格式化磁盘，它才会消失。不过现在很多系统软件如360和新版浏览器已经支持删除 flash cookie。百度采用了这样的技术记忆用户:session在浏览器关闭后也不会消失，除非正常退出，代码中使用了显式的unset删除session。否则session可能被收回，也有可能永远残留在系统中

// 4. session 比 cookie更安全吗？不应该大量使用cookie吗？
# 错。cookie确实可能存在一些不安全因素，但和javascript一样，即使突破前端验证，还有后端保证安全。一切都要看设计，尤其是涉及到权限的时候，特别需要注意。通常情况下，cookie和session是绑定的，获得cookie就相当于获得了session，客户端把劫持的cookie原封不动地传递给服务器，服务器收到后，原封不动得验证session，若session存在，就实现了cookie和session的绑定过程。因此，不存在session比cookie更安全这种说法。如果说不安全，也是由于代码不安全，错误地把用作身份验证地cookie作为权限验证来使用

// 5. session 是创建在服务器上的，应该少用session而多用cookie，对吗？
# 错。cookie可以提高用户体验，但会加大网络间的数据传输量，应尽量在cookie中仅保存必要的数据

// 6. 如果把别人机器上的 cookie 文件复制到我的电脑上（假设使用相同浏览器），是不是能登陆别人的账号呢？如何防范？
# 是的。这属于cookie劫持的一种做法。要避免这种情况，需要在cookie中针对ip ua等加上特殊的校验信息，然后和服务器进行对比。




# session 即会话，指一种持续性的、双向的连接。session 和 cookie 在本质上没什么区别，都是针对http协议的局限性而提出的一种保持客户端和服务器间连接状态的机制

# session 的实现可以有多种，如url重写、cookie，通过在cookie中存储sessionid实现session传递

# php 的 session 默认通过文件的方式实现，即存储在服务器端的session文件，每个session一个文件

# http 协议本身不能支持服务器端保存客户端的状态信息。为了解决这一问题，于是引入了session概念，用其来保存客户端的状态信息

# sessionID 实际上是在客户端和服务器之间通过 http request 和 http response 传来传去。

# sessionID 按照一定的算法生成，必须包含在 http request 里面，保证唯一性和随机性，以确保session的安全。

# 如果没有设置session的生命周期，sessionID存储在内存中，关闭浏览器后该ID自动注销；重新请求该页面，会重i性能注册一个sessionID。

# 如果客户端没有禁用Cookie，Cookie在启动session会话的时候扮演的时存储sessionID 和 session生存期的角色。

# 也可以使用 session_set_cookie_params() 函数设置session的生存期。session过期后，php会对其进行回收。因此，session并非都随着浏览器的关闭而消失的

# session 以文件的形式存放在本地硬盘的一个目录中，所以当session比较多时，磁盘读取文件就会比较慢。

# php.ini 中有一项: session.save_path = "N:MODE:/path"。 可以给session存放目录进行多级散列，N 表示要设置的目录级数，MODE表示目录的权限属性，默认为600。 windows 基本不用设置。 /path 表示session文件存放的根目录路径

# session 的回收是被动的，为了保证过期的session能被正常回收，可以修改php配置文件中的session.gc_divisor 参数以提高回收率（太大了会增加负载），或者设置一个变量是否过期。对于设置分级目录存储的session，php不会自动回收，需要自己实现其回收机制

































