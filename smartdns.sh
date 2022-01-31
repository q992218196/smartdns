#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

sh_url="raw.githubusercontent.com/q992218196/smartdns/main"
sh_ver="1.0.1"
smartdns_Release="35"
smartdns_ver="1.2021.08.27-1923"
smartdns_url="https://github.com/pymumu/smartdns/releases/download/Release${smartdns_Release}/smartdns.${smartdns_ver}.x86_64-linux-all.tar.gz"


#检测最新版本
Update_Shell(){
	echo -e "当前版本为 [ ${sh_ver} ]，开始检测最新版本..."
	sh_new_ver=$(wget --no-check-certificate -qO- "http://${sh_url}/smartdns.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1)
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} 检测最新版本失败 !" && menu
	if [[ ${sh_new_ver} != ${sh_ver} ]]; then
		echo -e "发现新版本[ ${sh_new_ver} ]，是否更新？[Y/n]"
		read -e -p "(默认: y):" yn
		[[ -z "${yn}" ]] && yn="y"
		if [[ ${yn} == [Yy] ]]; then
			wget -N --no-check-certificate http://${sh_url}/smartdns.sh && chmod +x smartdns.sh
			echo -e "脚本已更新为最新版本[ ${sh_new_ver} ] !"
		else
			echo && echo "	已取消..." && echo
		fi
	else
		echo -e "当前已是最新版本[ ${sh_new_ver} ] !"
		sleep 3s
	fi
	exit 0
}

#获取系统版本
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
}

#获取系统架构
check_version(){
	if [[ -s /etc/redhat-release ]]; then
		version=`grep -oE  "[0-9.]+" /etc/redhat-release | cut -d . -f 1`
	else
		version=`grep -oE  "[0-9.]+" /etc/issue | cut -d . -f 1`
	fi
	bit=`uname -m`
	if [[ ${bit} = "x86_64" ]]; then
		bit="x64"
	else
		bit="x32"
	fi
}

menu(){
    echo && echo -e "smartdns 一键安装脚本 浩瀚星辰 [v${sh_ver}]
    Tips：本脚本仅集成了一键安装功能，如需卸载请手动删除系统服务，请使用管理员权限运行
    Github：https://github.com/q992218196/
    
    1，开始安装
    2，检查脚本更新
    0，退出脚本
    "
    read -e -p " 请输入数字 [1-8]:" num
        case "$num" in
	    1)
	    smartdns_install
	    ;;
	    2)
	    Update_Shell
	    ;;
	    0)
	    exit 0
	    ;;
	    *)
	    echo "请输入正确的数字"
	    sleep 3s
	    menu
	    ;;
	    esac
}

smartdns_install(){
    if [[ ${release} == "centos" ]]; then
        yum install wget -y
    else
        apt install wget -y
    fi
    rm -rf /root/.smartdns
    wget ${smartdns_url} -O /root/.smartdns/smartdns_x86_64-linux-all.tar.gz
    tar -zxvf /root/.smartdns/smartdns_x86_64-linux-all.tar.gz
    chmod +x /root/.smartdns/smartdns/install
    ./root/.smartdns/smartdns/install -i
    echo "检查运行状态"
    systemctl status smartdns
}

check_sys
check_version
menu
