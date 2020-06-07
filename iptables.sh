[root@Jaking ~]# vim iptables.sh
#!/bin/bash

#��� filter ��� nat ��
iptables -F
iptables -t nat -F

#�ص� firewalld
systemctl stop firewalld &>/dev/null
systemctl disable firewalld &>/dev/null

#������������ĳЩ���� localhost ��Ӧ�÷���
iptables -A INPUT -i lo -j ACCEPT #����1
iptables -A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT #����2

#����һ������������ط� ping
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT #����3

#����һ����������������������豸���� MTU �����ı���
#��һЩ����£�����ͨ�� IPSec VPN ���ʱ�������� MTU ��Ҫ��̬��С
iptables -A INPUT -p icmp --icmp-type fragmentation-needed -j ACCEPT #����4

#�������зֱ�����������Դ���� TCP 80,443 �˿�
iptables -A INPUT -p tcp --dport 80 -j ACCEPT #����5
iptables -A INPUT -p tcp --dport 443 -j ACCEPT #����6

#����һ������������Դ���� UDP 80,443 �˿�
iptables -A INPUT -p udp -m multiport --dports 80,443 -j ACCEPT #����7

#����һ������ 192.168.1.63 ��Դ�� IP ���� TCP 22 �˿�(OpenSSH)
iptables -A INPUT -p tcp -s 192.168.1.63 --dport 22 -j ACCEPT #����8

#����һ������ 192.168.1.3(����SSH���ӵ�ϵͳ��Ӧ������IP) ��Դ�� IP ���� TCP 22 �˿�(OpenSSH)
#�������Զ���ն��ܱ��ű�����ÿ�������һ���Է����ߵ�
#��һ�ָ��Ӽ��ķ�ʽ��iptables -I INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -s 192.168.1.3 --dport 22 -j ACCEPT #����9

#����һ������ 192.168.1.26 ��Դ�� IP ���� UDP 161 �˿�(SNMP)
iptables -A INPUT -p udp -s 192.168.1.26 --dport 161 -j ACCEPT #����10

#���� NAT
#�����ں�·��ת������
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.conf
sysctl -p &>/dev/null

#����Դ��ַת�� SNAT
#�� 192.168.2.0/24 ת���� 192.168.1.63
iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -j SNAT --to 192.168.1.63 #����11

#����Ŀ�ĵ�ַת�� DNAT
#�� 192.168.1.63 �� 80 �˿�����ת���� 192.168.2.2 �� 80 �˿�
iptables -t nat -A PREROUTING -d 192.168.1.63 -p tcp --dport 80 -j DNAT --to 192.168.2.2:80 #����12

#����һ�н�ֹ���������Ľ�������
iptables -A INPUT -j DROP #����13

#����һ����������Ӧ������Ϊ 1-12 �����ݰ�����
iptables -A OUTPUT -m state --state ESTABLISHED -j ACCEPT #����14

#����һ�н�ֹ�������������ⲿ����
iptables -A OUTPUT -j DROP #����15

#����һ�н�ֹ����ת�����ݰ�
iptables -A FORWARD -j DROP #����16

#�̻� iptables
iptables-save > /etc/sysconfig/iptables