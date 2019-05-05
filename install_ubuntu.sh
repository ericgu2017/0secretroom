#install file for Ubuntu 16
echo "0SecretRoom easy install Ver: 1.0"
echo "**********************************************************************"
echo "如服务器在中国推荐使用mirrors.aliyun.com，是否允许我们调整/etc/apt/sources.list?"
echo "If the server is in China, shall we switch /etc/apt/sources.list to use mirrors.aliyun.com?"
echo 
echo "输入Y/y开始，其他键取消, Enter Y/y to switch, anything else to bypass"
read -p "Enter Y or y to start, anything else to bypass: " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo sed -i 's/archive.ubuntu/mirrors.aliyun/g' /etc/apt/sources.list
    echo "apt源已经替换成aliyun, apt repo has been switched to use aliyun"
fi
echo "**********************************************************************"
echo "推荐先跑一遍apt update更新一下系统"
echo "Shall we run apt update for you first? Highly recommended for a new system."
echo ""
echo "输入Y/y开始，其他键取消"
read -p "Enter Y or y to start, anything else to bypass: " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo apt update -y && sudo apt upgrade -y
fi
echo "**********************************************************************"
echo "安装正式开始，大概需要几分钟时间中间不能打断"
echo "Now we are going to start the installation, it takes several minutes and it can't be interupted"
echo 
echo "按Y/y开始，其他键取消"
read -p "Enter Y or y to start, anything else to quit: " -n 1 -r
echo 
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi
#download and install wget
sudo apt install wget -y
#install semanage
#yum install policycoreutils-python -y

#download dotnet sdk and install it
if [ ! -f "./dotnet-sdk-2.2.203-linux-x64.tar.gz" ]; then
    echo "dotnet install file not found, download a new one"
    wget https://swzbtest1.oss-cn-hangzhou.aliyuncs.com/dotnet-sdk-2.2.203-linux-x64.tar.gz
    sudo mkdir -p /root/dotnet && sudo tar zxf dotnet-sdk-2.2.203-linux-x64.tar.gz -C /root/dotnet
    export DOTNET_ROOT=/root/dotnet
    export PATH=$PATH:/root/dotnet
fi
#download 0secretroom
sudo mkdir /root/0secretroom -p
wget https://github.com/ericgu2017/0secretroom/releases/download/0.2/latest.tar.gz -O latest.tar.gz
sudo tar zxvf latest.tar.gz -C /root/0secretroom
sudo cp /root/0secretroom/web.service /etc/systemd/system
sudo systemctl enable web.service
sudo systemctl start web
#add firewalld rules
sudo ufw allow 80:81/tcp
sudo ufw allow 443/tcp
sudo ufw reload
#add nginx
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx

#put nginx to selinux permissive list
#semanage permissive -a httpd_t

#generate self-signed cert
echo "**********************************************************************"
echo "接下来要系统要产生一个自签名用于https加密的ssl证书，请根据英语界面提示输入"
echo "We will generate a self-signed ssl certificate, please follow the instruction to enter various information"
echo "Common name请输入0secretroom.local或者你正式域名，该域名指向必须设置到本服务器"
echo "Common name must be 0secretroom.local or a real domain name that pointed to this server"
echo 
echo -ne "请输入网站域名 please enter site domain name: "
read commonname
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/certs/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=$commonname"
#install nginx config file
echo "Now we are going to generate a new conf file for nginx to load"
sudo rm /etc/nginx/sites-enabled/default
sudo curl https://raw.githubusercontent.com/ericgu2017/0secretroom/master/nginx.conf -o /etc/nginx/sites-enabled/ssl.conf
echo "nginx conf file placed, trying to load it"
sudo nginx -s reload
echo "nginx reloaded"

#output results
#get local ip
myip=`hostname -I`
echo "**********************************************************************"
echo -e "All done, because WebCrypto API only works with https, we took the liberty and we generated a self-signed ssl key"
echo -e "If you do not have a real domain name you should add  \e[32m$myip $commonname\e[0m  to /etc/hosts and"
echo -e "try the following link in your browser: \e[32mhttps://$commonname/#/wschat?rid=aaa&uid=testadmin\e[0m"
echo -e "Please check-out our project site for details: \e[32mhttps://github.com/ericgu2017/0secretroom\e[0m"
echo -e "系统安装成功完成。由于WebCrypto API标准安全限制，本产品只能用于https环境"
echo -e "因此我们在安装过程中产生了一个用于https的自签名ssl证书"
echo -e "如果你没有正式域名，请自行把 \e[32m$myip $commonname\e[0m  添加到/etc/hosts文件中"
echo -e "浏览器访问地址:         \e[32mhttps://$commonname/#/wschat?rid=aaa&uid=testadmin\e[0m"
echo -e "如有问题请访问项目网站:  \e[32mhttps://github.com/ericgu2017/0secretroom\e[0m"
echo 
echo 
echo 
