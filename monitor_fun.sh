#!/bin/sh

function generate_monitor_data(){
data="\"CPU\":\"$(get_cpu_percentage)%\",\
\"MEM\":\"$(get_memory_percentage)%\",\
\"DISK\":\"$(get_disk_percentage)\",\
\"TIME\":\"$(date +%s)\""

echo ${data}

}

function get_cpu_percentage(){
    NOW_CPU_PERCENTAGE=`top -b -n2 -p 1 | grep "Cpu(s)" | tail -1|awk -F 'id,' -v prefix="$prefix" '{ split($1, vs, ","); v=vs[length(vs)]; sub("%", "", v); printf 100 - v }'`;
    echo ${NOW_CPU_PERCENTAGE}
}

function get_memory_percentage(){
    is_available=$(free | grep available | wc -l)
    if [ "$is_available" = "0" ]; then
      USED_MEMORY_PERCENTAGE="$(free | awk 'FNR == 3 {print $3/($3+$4)*100}')"
     else
      USED_MEMORY_PERCENTAGE="$(free | awk 'FNR == 2 {print ($2-$7)/$2*100}')"
     fi
     echo ${USED_MEMORY_PERCENTAGE}
}

function get_disk_percentage(){
    DISK_USAGE=" "
    for i in `lsblk -d | awk '{print $1}' | grep -v "NAME"`
    do		
      for j in `df -h | grep ${i} | awk '{print $1 "::" $5}'`
      do
        if [ ! $DISK_USAGE ]; then
          DISK_USAGE="${j}"
        else
          DISK_USAGE="${j},${DISK_USAGE}"
        fi
      done
    done
    echo ${DISK_USAGE}
}

function generate_log(){
     nowtime=`date --date='0 days ago' "+%Y-%m-%d-%H:%M:%S"`;
     echo ${nowtime} >> $1
     echo $2 >> $1
     echo "  " >> $1
     exit 0
}
