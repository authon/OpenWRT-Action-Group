#!/bin/sh
#网络检测脚本 通过PING来判断网络互通状态
#参数
#testing_ip=目标IP地址  detection_times=检测次数  Interval_time=间隔时间(秒)
#状态解释state
#start=开始检测  ok=网络连通  no=网络断开重试
#restart wan=重连WAN  restart wan ok=重连WAN完成
#restart network=重启网络进程  restart network ok=重启网络进程完成
#restart reboot=重启路由  restart reboot ok=重启路由完成
#脚本目录下日志文件my_pppoe.log 最大512K超出自动清空
#BY:朱君绰绰 V1.4
#其他重启命令
#ifup wan=重连WAN
#/etc/init.d/network restart=重启网络进程
#reboot=重启路由
#shell测试命令
#./my_pppoe.sh restart1
#echo $1

function Get_local_time(){
	date_time=`date +"%Y-%m-%d %H:%M:%S"`;
}
function text_log_size(){
	if [ -f $1 ]
	then
		filesize=`ls -l $1 | awk '{ print $5 }'`
		maxsize=$((1024*512))
		if [ $filesize -gt $maxsize ]
		then
			echo "$filesize > $maxsize"
			echo "log cleared" >$1
		else 
			echo "$filesize < $maxsize"
		fi
	fi 
}

testing_ip=114.114.114.114
testing_ip2=202.108.22.5
detection_times=3
Interval_time=10
detection_count=0
WebError=0
text_log=my_pppoe.log

text_log_size $text_log
Get_local_time
echo $date_time -- my_pppoe -- state:start >>$text_log
while [[ $detection_count -lt $detection_times ]]
do
	if /bin/ping -c 1 $testing_ip >/dev/null
    then
		Get_local_time
		echo $date_time -- my_pppoe -- state:ok ping=$testing_ip>>$text_log
		WebError=0
		break
	else	
		if /bin/ping -c 1 $testing_ip2 >/dev/null
		then
			Get_local_time
			echo $date_time -- my_pppoe -- state:no ping=$testing_ip -->>$text_log
			echo $date_time -- my_pppoe -- state:ok ping=$testing_ip2>>$text_log
			WebError=0
			break
		else
			detection_count=$((detection_count + 1))
			Get_local_time
			echo $date_time -- my_pppoe -- state:no ping=$testing_ip -->>$text_log
			echo $date_time -- my_pppoe -- state:no ping=$testing_ip2 -->>$text_log
			echo $date_time -- my_pppoe -- state:ping retry $detection_count-$detection_times>>$text_log
			WebError=1
			sleep $Interval_time
		fi
	fi
done

if [ $WebError = 1 ]
then
	if [ $1 = restart1 ]
	then
		Get_local_time
		echo $date_time -- my_pppoe -- state:restart wan >>$text_log
		ifup wan
		Get_local_time
		echo $date_time -- my_pppoe -- state:restart wan ok >>$text_log
	fi

	if [ $1 = restart2 ]
	then
		Get_local_time
		echo $date_time -- my_pppoe -- state:restart network >>$text_log
		/etc/init.d/network restart
		Get_local_time
		echo $date_time -- my_pppoe -- state:restart network ok >>$text_log
	fi	

	if [ $1 = restart3 ]
	then
		Get_local_time
		echo $date_time -- my_pppoe -- state:restart reboot >>$text_log
		Get_local_time
		echo $date_time -- my_pppoe -- state:restart reboot ok >>$text_log
		reboot
	fi
fi

exit 0



#end