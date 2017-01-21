# server-monitor-shell
server infrastructure monitor

###环境条件
   安装好redis-server和redis-cli
   
###执行命令
   ./monitor_server.sh
   
###增加到计划任务
    */1  *  *  *  * root /bin/sh /yourselftpath/monitor_server.sh
