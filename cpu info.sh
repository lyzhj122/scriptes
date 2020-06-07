#!/bin/bash
#filename: cpu-info.sh
#this script only works in a Linux system which has one or more identical physical CPU(s).

echo -n "logical CPU number in total: "
#�߼�CPU����
cat /proc/cpuinfo | grep "processor" | wc -l

#��Щϵͳû�ж��Ҳû�д򿪳��̣߳���ֱ���˳��ű�
cat /proc/cpuinfo | grep -qi "core id"
if [ $? -ne 0 ]; then
    echo "Warning. No multi-core or hyper-threading is enabled."
    exit 0;
fi

echo -n "physical CPU number in total: "
#����CPU����
cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l

echo -n "core number in a physical CPU: "
#ÿ������CPU��core�ĸ���(δ���볬�߳�)
core_per_phy_cpu=$(cat /proc/cpuinfo | grep "core id" | sort | uniq | wc -l)
echo $core_per_phy_cpu
echo -n "logical CPU number in a physical CPU: "
#ÿ������CPU���߼�CPU(������core��threads��both)�ĸ���
logical_cpu_per_phy_cpu=$(cat /proc/cpuinfo | grep "siblings" | sort | uniq | awk- F: '{print $2}')
echo $logical_cpu_per_phy_cpu

#�Ƿ�򿪳��̣߳��Լ�ÿ��core�ϵĳ��߳���Ŀ
#�����ͬһ������CPU�ϵ������߼�CPU������ͬ�ġ�core id������ô���߳��Ǵ򿪵�
#�˴�����ǰ������core_per_phy_cpu��logical_core_per_phy_cpu�ıȽ����鿴���߳�
if [ $logical_cpu_per_phy_cpu -gt $core_per_phy_cpu ]; then
    echo "Hyper threading is enabled. Each core has $(expr $logical_cpu_per_phy_cpu / $core_per_phy_cpu ) threads."
elif [ $logical_cpu_per_phy_cpu -eq $core_per_phy_cpu ]; then
    echo "Hyper threading is NOT enabled."
else
    echo "Error. There's something wrong."
fi