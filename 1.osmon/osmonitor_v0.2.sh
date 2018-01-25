#!/bin/sh
#create by toaddb ,any question mail to toaddb@163.com
#created 2016-2-6
if [ $# -ne 2 ]; then
	echo Invalid Arguments!
	echo "pls use like this : sh osmonitor.sh <interval> <times>" 
	exit 1
fi

pkill mpstat
pkill vmstat
pkill free
pkill iostat
pkill tp
pkill sar

tag=`date "+%m-%d-%H%M%S"`
mkdir osmonitor_data$tag

numactl --hardware > osmonitor_data$tag/1.numactl.log
cat /proc/cpuinfo > osmonitor_data$tag/2.cpuinfo.log
cat /proc/meminfo > osmonitor_data$tag/3.meminfo.log
cat /proc/version > osmonitor_data$tag/4.version.log
cat /proc/devices > osmonitor_data$tag/5.devices.log
cat /proc/modules > osmonitor_data$tag/6.modules.log
cat /proc/partitions > osmonitor_data$tag/7.partitions.log
cat /proc/swaps > osmonitor_data$tag/8.swaps.log
cat /proc/cmdline > osmonitor_data$tag/9.cmdline.log
dmesg > osmonitor_data$tag/10.dmesg.log
brctl show > osmonitor_data$tag/11.brctl.log
systemctl list-unit-files > osmonitor_data$tag/12.chkconfig.log
df > osmonitor_data$tag/13.df.log
ifconfig > osmonitor_data$tag/14.ifconfig.log
lspci > osmonitor_data$tag/15.lspci.log
lvdisplay > osmonitor_data$tag/16.lvdisplay.log
mount > osmonitor_data$tag/17.mount.log
rpm -qa > osmonitor_data$tag/18.rpm.log
vgdisplay > osmonitor_data$tag/19.vgdisplay.log



vmstat $1 $2 > osmonitor_data$tag/vmstat.log &
free $1 $2 > osmonitor_data$tag/free.log &
mpstat -P ALL $1 $2 > osmonitor_data$tag/mpstat.log &
mpstat -I SUM $1 $2 > osmonitor_data$tag/mpstat_interpt.log &
sar -n DEV $1 $2 > osmonitor_data$tag/sar_net.log &
sar -I ALL $1 $2 > osmonitor_data$tag/sar_interpt.log &
iostat -kx $1 $2 >  osmonitor_data$tag/iostat.log &

