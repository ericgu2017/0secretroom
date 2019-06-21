# ZeroSecretRoom
## A out-of-the-box working Html5 group chat (server-side code included) implementation with end-to-end encryption.

### Prerequisites

    To fully use this chatroom you need to understand the general idea of how to buy/operate/install software on general linux server on the cloud. 
    
### Need a domain name? ssl certificate?
    
    It's not necessary but without a domain name and/or a ssl certficate, you and your friend had to accept the usual pop-up from the browser saying the self-signed certificate is not safe. Other than that, no real danger or difference bewteen using a real thing vs self-signed ones.
    Why can't we support http instead of https?
    A: The real reason is that the encryption lib we used is called WebCrypto, it is an international standard which has been acccepted by ALL major browser maker including Google Chrome, Apple Safari and even Microsoft Edge. It only operates with https and for http it can only work under http://localhost/xxx  so that's the root cause. 
    Webcrypto stuff...
    https://developer.mozilla.org/en-US/docs/Web/API/Web_Crypto_API

### Installation

    Centos 7.x
    bash <(curl -H 'Cache-Control: no-cache' -L -s https://raw.githubusercontent.com/ericgu2017/0secretroom/master/install_centos7.sh)
    
    Ubuntu 16.x & 18.x & 19.x
    bash <(curl -H 'Cache-Control: no-cache' -L -s https://raw.githubusercontent.com/ericgu2017/0secretroom/master/install_ubuntu.sh)
    
    

Demo video
https://youtu.be/f1aJCYCM8LE

### Features

- the chatrom client is a web app. It can be run on Google Chrome, Safari, Android Google Chrome, iOS Safari, Opera and many more. Wechat even but we do __NOT__ recommend doing so.
- ALL transmittions between the relay server and the clients are encrypted with dynamically changing keys (based on AES)
- The relay server doesn't have access to any keys used to encrypt transmissions.
- The relayed messages (and fully encrypted) will be kept on the server for a very short period of time and it will be utterly deleted if all members in the room have recieved the message.
- The relay server keeps everything in memory, it doesn't use Mysql or any other persistant storage.
- The room creator can restore the room after server reboot, fully automaticlally
- It support jpg/png/gif/mp4/mkv and much more files to be uploaded and shows in the chatroom.
- Mobile devices tested: iPad Pro (10 inches), iPhone 6/7/8/XR, Oneplus 6T, Samsung Note8.

### What's been used?
- websockets or specifically, Microsoft SignalR, for instant messeging between relay server and the clients.
- AES256 to encrypt all the messeges.
- ECDH was used to safely transfer the mainkey (AES256 key) on the Internet (ECDH derivekey to create a temp AESkey and use that to encrypt the real key).
- WebCrypto was used to greatly enhanced the encryption/decryption speed on the web. (https://www.w3.org/TR/WebCryptoAPI/)
- Vue js framework
- dotnet core server web services

### What's for?
- Self-host a small and yet fully functional chatroom for a group of friends to share stuff safely and quietly. (normally <100 users for a tiny virtual server) 
- Your own one-person data relay service to pass something from your phone to your PC or Mac.
- It can support many chatrooms and a lot many users on a more powerful server setting. I will test it out in the future. But the server uses very little memory to run.

### What's not?
- A production grade high level security chatroom used in Gov'nt and any simular situations.
- Anything serious

### Security concerns
- The default room rid=aaa is not secure and it can only be used in a demo situation because the AESkey is fixed (this is by design, room aaa is used in unit test). for real security room please create a new room from the menu and invite people in that room.

视频简介
https://youtu.be/f1aJCYCM8LE

闪亮的功能点

- 这个东西是一个浏览器中的应用。完美工作在最新（或者前一个版本）的谷歌Chrome，苹果电脑Safari，安卓手机上的Chrome，苹果手机移动Safari，以及其他一些常用桌面浏览器中（Firefox，Opera等等）
- 所有客户端和服务器的通信全部加密传输（数据传输AES256，key exchange过程使用ECDH，js代码完全基于WebEncryption API）
- 服务器不会收到任何用于加密的密钥
- relay的消息（加密的）会在服务器存在一段时间，然后当所有人都收到后会被删除
- 服务器只使用内存，服务器不会使用任何硬盘或者数据库资源。数据都暂存在客户端本地包括加密解密密钥，所有收到的聊天消息，聊天室里面的所有的人
- 全程加密文件传输支持：jpg，png，gif动画，MP4和mkv视频（20MB左右大概需要5-10秒传输200mpbs网络环境）
- 移动手机测试通过：iPad Pro（10寸），iPhone 6/7/8/XR，一加6T，三星Note8。基本上只要6GB内存或者以上的基于google chrome内核或者苹果Safari都可以。内存越大，性能越好。

用到的技术

- websockets，使用的是微软的signalr框架
- AES256用来加密解密传输信息
- ECDH P-256用来不实际传输key，同时把实际的key传给对方，具体可以参考wiki，下文也有一个简述可以参考一下
https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange#/media/File:Diffie-Hellman_Key_Exchange.svg
https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange
- webcrypto api，这个是目前被主流浏览器支持的，全平台的，加速后的泡在浏览器中的加密解密套件框架。类似html5标准一样的一个标准。拿google chrome举例
在windows上的google chrome背后调用系统unmanaged code来实际完成加密解密任务。具体可以参考
https://developer.mozilla.org/en-US/docs/Web/API/Web_Crypto_API
- dotnet core for the server platform and vue.js 2.x/3.x for the actual webclient

使用场景举例
新建和邀请

- 张三创建了一个聊天室。在创建的时候他浏览器中初始化冰保存了主AES256的key
- 张三创建了一个邀请链接（或者二维码）给李四。李四扫码访问了这个链接。
- 这个时候张三和李四会各自创建一对ecdh公钥私钥，然后相互交换各自的公钥，最后并且使用ECDH中derivekey功能获得一个临时的aes256的key
- ECDH私钥只存在于张三李四各自浏览器上，并不会传输到服务器。而derivekey必须要用到各自的私钥。服务器只拿到了各自公钥，所以没用。而且
- 每次邀请新人都会重新创建ECDH密钥对
- 张三李四使用这个临时的aes256key来加密传输实际的房间主aes256key。最后，李四拿到了主aes256key，李四加入了聊天室
- 张三和李四从此和睦的生活在一起

登录
- 用户打开曾经访问过该聊天室的浏览器
- 浏览器自动登录注册websocket链接
- 服务器会判断用户是否有权利访问聊天室，如果查无此人则回绝。客户端会显示登录失败并结束访问

传输
- 张三发消息。消息被加密后通过websocket传到服务器
- 服务器完全不动直接转发给所有同聊天室人等。等到所有人都确认收到后，服务器把他从内存删除
- 群众从websocket收到推送的加密消息，然后各自解密显示。同时通过websocket汇报服务器收到
- 大的图片视频资源都会被保存在浏览器indexeddb本地存储。不会使用有容量限制的localstorage。indexeddb一般会有几个GB到10-20%整个硬盘容量

多登
- 张三在手机上创建自己的多登链接（或者二维码）
- 张三在另外一台设备上直接用多登链接访问，登入聊天室
- 多登设备数量没有限制。理论上可以在所有手机，电脑设备上登录同一个账号，互通有无
- 张三可以在任意已经登录设备上管理删除其他登录设备（未来功能）

安全性
- 默认rid=aaa的聊天室只能用于测试，他的房间的主AESkey是固定的。请从菜单中创建新的聊天室然后再邀请其他人

