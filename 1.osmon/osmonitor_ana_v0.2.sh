#!/bin/sh
#create by toaddb, any questions pls email to : toaddb@163.com
#HangZhou
if [ $# -ne 1 ]; then
	echo Invalid Arguments!
	echo "pls use like this : sh osmonitor_ana.sh <path>" 
	echo for example :sh osmonitor_ana.sh osmonitor_data02-04-173118
	echo "create by toaddb,any questions pls email to : toaddb@163.com"
	exit 1
fi
rm -rf ${1}_ana
mkdir ${1}_ana
function warning()
{
	if [[ $1 = ok ]]; then
		echo -e "$2 is checked:\033[;32m ok \033[0m  $3"
	else
		echo -e "$2 is checked:\033[;31m failed ,pls attention:  $2 \033[0m $3"
	fi
}

function delete_tmp()
{
	rm -rf vmstat_ana.tmp.log
	rm -rf soft_ana.tmp.log
	rm -rf io_ana.tmp.log
	rm -rf iostat_tmp.log
	rm -rf cpu_ana.tmp.log
	rm -rf index.tmp.log
}

#get key words col number
function get_word_col_number()
{
        #get the col number
        index=0
        cat $1  | grep $2 | xargs | sed 's/ /\n/g' > index.tmp.log
        while read line
        do
                if [[ $line = $2 ]]; then
                        let index++;
                        break
                else
                        let index++;
                fi
        done < index.tmp.log
	echo $index
	
}
# analyze the vmstat data 
function ana_vmstat()
{
	#get the col number 
	index=`get_word_col_number $1/vmstat.log swpd`

	cat $1/vmstat.log  | awk  '{print $i}' i=$index | grep ^[0-9] | xargs  > vmstat_ana.tmp.log	
	sed -i s/[[:space:]]//g vmstat_ana.tmp.log 
	used=`cat vmstat_ana.tmp.log`
        result=`expr $used + 1`	
        if [[ $result = 1 ]];then
		warning ok "virtual memory used" "no swap using"
	else
		warning error "virtual memory used"
	fi	
	return 0 
}
# analyze the free data
function ana_free()
{
	
	freed=`cat /proc/meminfo  | grep MemFree | awk '{print $2}'`
	freed=`expr $freed + 0`
        if [[ $freed < 1048567 ]];then
		warning error "memory free" "free memory is less than 1GB"
	else
		warning ok "memory free" "free memory is bigger than 1 GB"
	fi	
	return 0 
}


function ana_mpstat()
{
	#pre do with mpstat.log
	sed -i /^Linux/d $1/mpstat.log 	
	sed -i /^Average/d $1/mpstat.log 

	#get the col number
        index1=`get_word_col_number $1/mpstat.log CPU`
        index2=`get_word_col_number $1/mpstat.log %soft`

        cat $1/mpstat.log |grep -v Average | awk '{print $i " " $j}' i=$index1 j=$index2  | grep ^[0-9] > soft_ana.tmp.log
	flag="0"
        while read line
        do
		test=`echo $line | awk '{print $2}' | awk -F . '{print $1}'`
                if [[ ${test} -le 10 ]];then
			continue
                fi
		flag="1"
        done < soft_ana.tmp.log
	if [ $flag = "1" ];then
		warning error "soft interrupt: " " some core may be busy with soft interrupt more than 10%"
	else
		warning ok "soft interrupt " "every core's soft interrupt is less than 10%"
	fi
        return 0
}


function ana_iostat()
{
	
	rm -rf iostat_tmp.log
        k=`cat $1/iostat.log | grep -n avg-cpu | awk -F : '{print $1}' | head -n 2 | tail -n 1 `
	tail -n +${k} $1/iostat.log > iostat_tmp.log

	index=`get_word_col_number iostat_tmp.log %util`	

	cat iostat_tmp.log | grep -v Device | grep -v Linux | grep -v  avg-cpu | awk '{print $1 " " $i}' i=$index | grep -v ^[0-9] | grep ^[a-z] > io_ana.tmp.log
	flag="0"

	while read line
        do
                test=`echo $line | awk '{print $2}' | awk -F . '{print $1}' ` 
                if [[ ${test} -le 50  ]];then
                        continue
                fi
		flag="1"
        done < io_ana.tmp.log	
	if [ $flag = "1" ];then
		warning error "io status: " " some disk utility is more than 50%"
	else
		warning ok "io status:" "each disk utility is less than 50%"
	fi
	return 0 
}
function ana_iolatency()
{
	rm -rf iostat_tmp.log
        k=`cat $1/iostat.log | grep -n avg-cpu | awk -F : '{print $1}' | head -n 2 | tail -n 1 `
        tail -n +${k} $1/iostat.log > iostat_tmp.log
	#get col number

	index=`get_word_col_number iostat_tmp.log await`	

        cat iostat_tmp.log | grep -v Device | grep -v Linux | grep -v  avg-cpu | awk '{print $1 " " $i}' i=$index | grep -v ^[0-9] | grep ^[a-z] > io_ana.tmp.log
        flag="0"
        while read line
        do
                test=`echo $line | awk '{print $2}' | awk -F . '{print $1}' `
                if [[ ${test} -le 20  ]];then
                        continue
                fi
                flag="1"
        done < io_ana.tmp.log
        if [ $flag = "1" ];then
                warning error "io latency: " " some disk latency is much than 20ms,pls attention"
        else
                warning ok "io latency:" " each disk latency is less than 20ms"
        fi
	return 0
}
function ana_cpu()
{

	index1=`get_word_col_number $1/mpstat.log CPU`
	index2=`get_word_col_number $1/mpstat.log %idle`

        cat $1/mpstat.log |grep -v Average | awk '{print $i " " $j}' i=$index1 j=$index2 | grep ^[0-9] > cpu_ana.tmp.log
        flag="0"

        while read line
        do
                test=`echo $line | awk '{print $2}' | awk -F . '{print $1}'`
                if [[ ${test} -ge 5 ]];then
                        continue
                fi
                flag="1"
        done < cpu_ana.tmp.log
        if [ $flag = "1" ];then
                warning error "cpu utility: " " some core is used more than 95%,pls attention"
        else
                warning ok "cpu utility: " "every core is under 95%"
        fi

	return 0
}

delete_tmp;
ana_vmstat $1
ana_free $1
ana_mpstat $1
ana_iostat $1
ana_iolatency $1
ana_cpu $1
#delete_tmp;
echo "*********************************"
echo "any pls email to toaddb@163.com"
