
#get the CPU info
cores=`cat /proc/cpuinfo | grep "model name" | wc -l`
echo "cores = " $cores >> hwinfo.log
cpuinfo=`cat /proc/cpuinfo | grep "model name" | uniq`
echo "cpuinfo = " $cpuinfo >> hwinfo.log
