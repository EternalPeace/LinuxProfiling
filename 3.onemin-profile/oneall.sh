
if [ $# != 2 ] ; then 
	echo " e.g.: $0 javaperformance 10"
	exit 1;
fi 
if [ $2 -lt 10 ]; then
        echo "USAGE: $0 TAG monitortime[s](should be larger than 10)" 
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

pkill vmstat
pkill mpstat
pkill pidstat
pkill iostat
pkill sar
cd $dirname
uptime > uptime.log
dmesg > dmesg.log
vmstat 1 $2 > vmstat.log &
mpstat -P ALL 1 $2 > mpstat.log &
pidstat 1 $2 > pidstat.log &
iostat -xz 1 $2 > iostat.log &
free -m > free.log 
sar -n DEV 1 $2 > network.log &
sar -n TCP,ETCP 1 $2 > tcp.log &
sh ../hardwareinfo.sh 
echo "selecting performance data,please wait...$2 seconds"
wait=$2
while [ $wait -ge 0 ];do
	wait=$(($wait-10))
	sleep 10
	echo '.\c'
done
	echo '\n'
if [ $wait -lt 0 ];then
	wait=$(($wait+10))	
	echo "wait $wait seconds,soon to complete"
	sleep $wait
fi
echo "exit..."
