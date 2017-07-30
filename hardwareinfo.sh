
#get the CPU info
mkdir hwinfo
cd hwinfo
cores=`cat /proc/cpuinfo | grep "model name" | wc -l`
echo "cores = " $cores >> hwinfo.log
cpuinfo=`cat /proc/cpuinfo | grep "model name" | uniq`
echo "cpuinfo = " $cpuinfo >> hwinfo.log
