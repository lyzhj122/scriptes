[root@Jaking ~]# vim iptables.sh
#!/bin/bash

#清空 filter 表和 nat 表
iptables -F
iptables -t nat -F

#关掉 firewalld
systemctl stop firewalld &>/dev/null
systemctl disable firewalld &>/dev/null

#以下两行允许某些调用 localhost 的应用访问
iptables -A INPUT -i lo -j ACCEPT #规则1
iptables -A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT #规则2

#以下一行允许从其他地方 ping
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT #规则3

#以下一行允许从其他主机、网络设备发送 MTU 调整的报文
#在一些情况下，例如通过 IPSec VPN 隧道时，主机的 MTU 需要动态减小
iptables -A INPUT -p icmp --icmp-type fragmentation-needed -j ACCEPT #规则4

#以下两行分别允许所有来源访问 TCP 80,443 端口
iptables -A INPUT -p tcp --dport 80 -j ACCEPT #规则5
iptables -A INPUT -p tcp --dport 443 -j ACCEPT #规则6

#以下一行允许所有来源访问 UDP 80,443 端口
iptables -A INPUT -p udp -m multiport --dports 80,443 -j ACCEPT #规则7

#以下一行允许 192.168.1.63 来源的 IP 访问 TCP 22 端口(OpenSSH)
iptables -A INPUT -p tcp -s 192.168.1.63 --dport 22 -j ACCEPT #规则8

#以下一行允许 192.168.1.3(发起SSH连接的系统对应网卡的IP) 来源的 IP 访问 TCP 22 端口(OpenSSH)
#如果是在远程终端跑本脚本，最好开启以下一行以防被踢掉
#另一种更加简便的方式：iptables -I INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -s 192.168.1.3 --dport 22 -j ACCEPT #规则9

#以下一行允许 192.168.1.26 来源的 IP 访问 UDP 161 端口(SNMP)
iptables -A INPUT -p udp -s 192.168.1.26 --dport 161 -j ACCEPT #规则10

#配置 NAT
#启用内核路由转发功能
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.conf
sysctl -p &>/dev/null

#配置源地址转换 SNAT
#将 192.168.2.0/24 转换成 192.168.1.63
iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -j SNAT --to 192.168.1.63 #规则11

#配置目的地址转换 DNAT
#将 192.168.1.63 的 80 端口请求转发到 192.168.2.2 的 80 端口
iptables -t nat -A PREROUTING -d 192.168.1.63 -p tcp --dport 80 -j DNAT --to 192.168.2.2:80 #规则12

#以下一行禁止所有其他的进入流量
iptables -A INPUT -j DROP #规则13

#以下一行允许本机响应规则编号为 1-12 的数据包发出
iptables -A OUTPUT -m state --state ESTABLISHED -j ACCEPT #规则14

#以下一行禁止本机主动发出外部连接
iptables -A OUTPUT -j DROP #规则15

#以下一行禁止本机转发数据包
iptables -A FORWARD -j DROP #规则16

#固化 iptables
iptables-save > /etc/sysconfig/iptables