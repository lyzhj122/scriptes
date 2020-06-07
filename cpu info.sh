#!/bin/bash
#filename: cpu-info.sh
#this script only works in a Linux system which has one or more identical physical CPU(s).

echo -n "logical CPU number in total: "
#逻辑CPU个数
cat /proc/cpuinfo | grep "processor" | wc -l

#有些系统没有多核也没有打开超线程，就直接退出脚本
cat /proc/cpuinfo | grep -qi "core id"
if [ $? -ne 0 ]; then
    echo "Warning. No multi-core or hyper-threading is enabled."
    exit 0;
fi

echo -n "physical CPU number in total: "
#物理CPU个数
cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l

echo -n "core number in a physical CPU: "
#每个物理CPU上core的个数(未计入超线程)
core_per_phy_cpu=$(cat /proc/cpuinfo | grep "core id" | sort | uniq | wc -l)
echo $core_per_phy_cpu
echo -n "logical CPU number in a physical CPU: "
#每个物理CPU中逻辑CPU(可能是core、threads或both)的个数
logical_cpu_per_phy_cpu=$(cat /proc/cpuinfo | grep "siblings" | sort | uniq | awk- F: '{print $2}')
echo $logical_cpu_per_phy_cpu

#是否打开超线程，以及每个core上的超线程数目
#如果在同一个物理CPU上的两个逻辑CPU具有相同的”core id”，那么超线程是打开的
#此处根据前面计算的core_per_phy_cpu和logical_core_per_phy_cpu的比较来查看超线程
if [ $logical_cpu_per_phy_cpu -gt $core_per_phy_cpu ]; then
    echo "Hyper threading is enabled. Each core has $(expr $logical_cpu_per_phy_cpu / $core_per_phy_cpu ) threads."
elif [ $logical_cpu_per_phy_cpu -eq $core_per_phy_cpu ]; then
    echo "Hyper threading is NOT enabled."
else
    echo "Error. There's something wrong."
fi