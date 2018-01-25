
if [ $# != 1 ] ; then 
	echo "USAGE: $0 TAG" 
	echo " e.g.: $0 javaperformance"
	exit 1; 
fi 


dirname=`date "+%Y%m%d-$1"`
#判断是否已存在文件夹
if [ ! -d "$dirname" ]; then
	 mkdir "$dirname"
else
	echo "The file is exists,please name another TAG"
	exit 1;
fi

cd $dirname
uptime > uptime.log
dmesg > dmesg.log
vmstat 1 5 > vmstat.log
mpstat -P ALL 1 5 > mpstat.log
pidstat 1 5 > pidstat.log
iostat -xz 1 5 > iostat.log
free -m > free.log
sar -n DEV 1 5 > network.log
sar -n TCP,ETCP 1 5 > tcp.log
