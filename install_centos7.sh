#install file for CentOS 7
#yum update
echo "********************************************************************"
echo "推荐先跑一遍yum update更新一下系统"
echo "Shall we run yum update for you first? Highly recommended for a new system."
echo "********************************************************************"
echo ""
echo "输入Y/y开始，其他键取消"
read -p "Enter Y or y to start, anything else to bypass." -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    yum update -y
fi
echo "********************************************************************"
echo "安装正式开始，大概需要几分钟时间中间不能打断"
echo "Now we are going to start the installation, it takes several minutes and it can't be interupted"
echo "********************************************************************"
echo 
echo "按Y/y开始，其他键取消"
read -p "Enter Y or y to start, anything else to quit." -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi
#download and install wget
sudo yum install wget -y
#install semanage
yum install policycoreutils-python -y

#download dotnet sdk and install it
if [ ! -f "./dotnet-sdk-2.2.203-linux-x64.tar.gz" ]; then
    echo "dotnet install file not found, download a new one"
    wget https://swzbtest1.oss-cn-hangzhou.aliyuncs.com/dotnet-sdk-2.2.203-linux-x64.tar.gz
    mkdir -p $HOME/dotnet && tar zxf dotnet-sdk-2.2.203-linux-x64.tar.gz -C $HOME/dotnet
    export DOTNET_ROOT=$HOME/dotnet
    export PATH=$PATH:$HOME/dotnet
fi
#download 0secretroom
mkdir 0secretroom -p
wget https://github.com/ericgu2017/0secretroom/releases/download/0.2/latest.tar.gz -O latest.tar.gz
tar zxvf latest.tar.gz -C 0secretroom
cp 0secretroom/web.service /etc/systemd/system
systemctl enable web.service
systemctl start web
#add firewalld rules
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=81/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload
#add nginx
sudo yum install epel-release -y
sudo yum install nginx -y
systemctl enable nginx
systemctl start nginx

#put nginx to selinux permissive list
semanage permissive -a httpd_t

#generate self-signed cert
echo "********************************************************************"
echo "接下来系统要产生一个用于https加密的自签名ssl证书，请根据提示输入"
echo "We will generate a self-signed ssl certificate, please follow the instructions"
echo "Common name请输入abc.local或者一个正式指向本服务器的域名"
echo "Common name can be something like abc.local or a real domain name that points to this server"
echo "********************************************************************"
echo 
echo -ne "请输入Common name; Please enter common name: "
read commonname
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/certs/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=$commonname"
#install nginx config file
curl https://raw.githubusercontent.com/ericgu2017/0secretroom/master/nginx.conf -o /etc/nginx/conf.d/nginx.conf
nginx -s reload


#output results
#get local ip
myip=`hostname -I`
echo "**********************************************************************************"
echo -e "All done, because WebCrypto API only works with https, we took the liberty and we generated a self-signed ssl key"
echo -e "If you do not have a real domain name you should add  \e[32m$myip $commonname\e[0m  to /etc/hosts and"
echo -e "try the following link in your browser: \e[32mhttps://$commonname/#/wschat?rid=aaa&uid=testadmin\e[0m"
echo -e "Please check-out our project site for details: \e[32mhttps://github.com/ericgu2017/0secretroom\e[0m"
echo -e "系统安装成功完成。由于WebCrypto API标准安全限制，本产品只能用于https环境"
echo -e "因此我们在安装过程中产生了一个用于https的自签名ssl证书"
echo -e "如果你没有正式域名，请自行把 \e[32m$myip $commonname\e[0m  添加到/etc/hosts文件中"
echo -e "浏览器访问地址:         \e[32mhttps://$commonname/#/wschat?rid=aaa&uid=testadmin\e[0m"
echo -e "如有问题请访问项目网站:  \e[32mhttps://github.com/ericgu2017/0secretroom\e[0m"
echo "**********************************************************************************"
