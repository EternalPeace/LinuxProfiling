uptime > uptime.log
dmesg > dmesg.log
vmstat 1 5 > vmstat.log
mpstat -P ALL 1 5 > mpstat.log
pidstat 1 5 > pidstat.log
iostat -xz 1 5 > iostat.log
free -m > free.log
sar -n DEV 1 5 > network.log
sar -n TCP,ETCP 1 5 > tcp.log
