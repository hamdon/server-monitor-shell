#!/bin/sh
#
#  get ps aux about cpu percentage
#set -e
#set -x

PREFIX=$(cd "$(dirname "$0")"; pwd)
cd $PREFIX

cur_dir=$(pwd)
source "${cur_dir}/monitor_config.sh"
source "${cur_dir}/monitor_fun.sh"

CURRENT_SERVER_INFO="\"${SERVER_NAME}\":{\"ip\":\"${SERVER_IP}\",\"data\":\"${SERVER_MONITOR_NAME}\"}";

error_log="monitor_error_info.log"
error_log_path="${cur_dir}/${error_log}"

#获取redis里面服务器信息的数据
if [ ! $REDIS_AUTH ]; then
   WEB_MONITOR="$(${REDIS_CLI} -h ${REDIS_IP} -p ${REDIS_PORT} get ${ALL_SERVERS_INFO_SET})"
else
   WEB_MONITOR="$(${REDIS_CLI} -h ${REDIS_IP} -p ${REDIS_PORT} -a ${REDIS_AUTH} get ${ALL_SERVERS_INFO_SET})"
fi

#判断redis里面有没有服务器信息的变量，如果没有，就初始化
if [ ! $WEB_MONITOR ]; then 
 if [ ! $REDIS_AUTH ]; then
   result="$(${REDIS_CLI} -h ${REDIS_IP} -p ${REDIS_PORT} set ${ALL_SERVERS_INFO_SET} {${CURRENT_SERVER_INFO}})"
 else
   result="$(${REDIS_CLI} -h ${REDIS_IP} -p ${REDIS_PORT} -a ${REDIS_AUTH} set ${ALL_SERVERS_INFO_SET} {${CURRENT_SERVER_INFO}})"
 fi
 if [ ! $result ]; then
  generate_log $error_log_path "连接不上redis服务器或者给redis增加初始化数量出错!"
 fi
else 
  #判断本机的信息有没有在服务器信息变量里面，如果没有，增加.
  result=$(echo $WEB_MONITOR | grep "${CURRENT_SERVER_INFO}")
  if [[ "$result" = "" ]] ;then
    new_web_monitor="{${CURRENT_SERVER_INFO},${WEB_MONITOR:1}"
    if [ ! $REDIS_AUTH ]; then
       result="$(${REDIS_CLI} -h ${REDIS_IP} -p ${REDIS_PORT} set ${ALL_SERVERS_INFO_SET} ${new_web_monitor})"
    else
       result="$(${REDIS_CLI} -h ${REDIS_IP} -p ${REDIS_PORT} -a ${REDIS_AUTH} set ${ALL_SERVERS_INFO_SET} ${new_web_monitor})"
    fi
    if [ ! $result ]; then
      generate_log $error_log_path "连接不上redis服务器或者给redis中增加服务器信息出错!"
    fi 
  fi
fi

if [ ! $REDIS_AUTH ]; then
    result="$(${REDIS_CLI} -h ${REDIS_IP} -p ${REDIS_PORT} set ${SERVER_MONITOR_NAME} {$(generate_monitor_data)})"
else
    result="$(${REDIS_CLI} -h ${REDIS_IP} -p ${REDIS_PORT} -a ${REDIS_AUTH} set ${SERVER_MONITOR_NAME} {$(generate_monitor_data)})"
fi
if [ ! "$result" ]; then
     generate_log $error_log_path "给redis增加服务器监控数据出错!"
fi 

