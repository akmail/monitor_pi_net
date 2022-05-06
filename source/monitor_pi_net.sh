#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run monitor_pi_net.sh as root"
  exit 0
fi

# html report template file
TMPL_PATH="/var/lib/monitor_pi_net"

# html report destination directory
TARGET_PATH="/media/monitor_pi_net"

# approx. interval in seconds to re-generate system info
SYSINFO_PERIOD=1800
LAST_RENDERED=$SYSINFO_PERIOD

# generate html page index.html from template into $TARGET_PATH
renderhtml(){
    echo "$(tail -100 $TARGET_PATH/network_outage.log)" > $TARGET_PATH/network_outage.log
    echo "$(tail -100 $TARGET_PATH/ping.log)" > $TARGET_PATH/ping.log

    status_all=""
    status_all="$(date +'%a %Y-%m-%d %H:%M:%S') $COUNT pings per host, timeout $TIMEOUT s, retry $INTERVALL s, cycle $CYCLE s\n"
    host=1
    for hostname in $HOSTS
    do
        status_all="$status_all${status_str[host]}\n"
        host=$((host+1))
    done

    # update network status
    echo -en "$status_all" > $TARGET_PATH/status.log

    if [ "$LAST_RENDERED" -ge "$SYSINFO_PERIOD" ]; then
        echo -n "System info generated: " > $TARGET_PATH/sysinfo.log
	date >> $TARGET_PATH/sysinfo.log
	
        # OS info
        uname -a >> $TARGET_PATH/sysinfo.log
        if [ -f "/etc/os-release" ]; then
            cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' >> $TARGET_PATH/sysinfo.log
        fi

        if [ -f "/usr/bin/vcgencmd" ]; then
            # Raspberry memory split
            vcgencmd get_mem arm >> $TARGET_PATH/sysinfo.log
	    vcgencmd get_mem gpu >> $TARGET_PATH/sysinfo.log
    
            # CPU takt rate
	    echo -n "current clock speed: " >> $TARGET_PATH/sysinfo.log; cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq >> $TARGET_PATH/sysinfo.log
    	    echo -n "maximum clock speed: " >> $TARGET_PATH/sysinfo.log; vcgencmd get_config arm_freq >> $TARGET_PATH/sysinfo.log
        
	    # CPU temperature
            /opt/vc/bin/vcgencmd measure_temp >> $TARGET_PATH/sysinfo.log
        fi

        # available system updates
        apt-get update > /dev/null
        echo "Available system updates:" >> $TARGET_PATH/sysinfo.log
        apt-get -s upgrade | tail -n+4 >> $TARGET_PATH/sysinfo.log

        # free memory
        echo >> $TARGET_PATH/sysinfo.log
        free -h >> $TARGET_PATH/sysinfo.log

        # disk space
        echo >> $TARGET_PATH/sysinfo.log
        df -h >> $TARGET_PATH/sysinfo.log

        # top
        echo >> $TARGET_PATH/sysinfo.log
        top -b -n1 -o TIME | head -n 35 >> $TARGET_PATH/sysinfo.log

        if [ -e /var/log/cpu_temp/cpu_temp.log ]; then 
            echo >> $TARGET_PATH/sysinfo.log
            echo 'cpu_temp.log' >> $TARGET_PATH/sysinfo.log
            echo '------------' >> $TARGET_PATH/sysinfo.log
            tail -n120 /var/log/cpu_temp/cpu_temp.log | column -t >> $TARGET_PATH/sysinfo.log
	fi

        if [ -e /home/pi/.kodi/temp/kodi.log ]; then 
            echo >> $TARGET_PATH/sysinfo.log
            echo 'kodi.log' >> $TARGET_PATH/sysinfo.log
            echo '--------' >> $TARGET_PATH/sysinfo.log
            tail -n40 /home/pi/.kodi/temp/kodi.log >> $TARGET_PATH/sysinfo.log
        fi

        if [ -e /var/log/unattended-upgrades/unattended-upgrades.log ]; then 
            echo >> $TARGET_PATH/sysinfo.log
            echo 'unattended-upgrades.log' >> $TARGET_PATH/sysinfo.log
            echo '-----------------------' >> $TARGET_PATH/sysinfo.log
            tail -n40 /var/log/unattended-upgrades/unattended-upgrades.log | fold -w 80 -s >> $TARGET_PATH/sysinfo.log
	fi

        if [ -e /var/log/syslog ]; then 
            echo >> $TARGET_PATH/sysinfo.log
            echo 'syslog' >> $TARGET_PATH/sysinfo.log
            echo '------' >> $TARGET_PATH/sysinfo.log
            tail -n80 /var/log/syslog >> $TARGET_PATH/sysinfo.log
	fi
	tail -n 80 

        # open port
        echo >> $TARGET_PATH/sysinfo.log
        netstat -tulpn >> $TARGET_PATH/sysinfo.log

        LAST_RENDERED=0
    else
        LAST_RENDERED=$(($LAST_RENDERED+$CYCLE))
    fi
}

# kill signal received - log and exit the script
function clean_up {
    # Perform program exit housekeeping
    echo "$(date +'%a %Y-%m-%d %H:%M:%S') received shutdown signal, exiting." | tee -a $TARGET_PATH/network_outage.log
    exit 0
}

# SIGHUP signal received - do nothing because this is a service script and it should
# continue executing even after its terminal has been terminated
function hangup {
    # do nothing
    :
}

# set some default values
COUNT=2
INTERVALL=4
TIMEOUT=6
CYCLE=60
TEMPLATE="index.tmpl"

if [ -f "/etc/monitor_pi_net.conf" ]; then
    # read configuration from conf file
    echo "$(date +'%a %Y-%m-%d %H:%M:%S') INFO: config file found under /etc/monitor_pi_net.conf, ignoring parameters." | tee -a $TARGET_PATH/network_outage.log

    source /etc/monitor_pi_net.conf
    COUNT=$pings_per_host
    INTERVALL=$pause_on_ping_fail
    TIMEOUT=$ping_timeout
    CYCLE=$pause_between_cycles
    HOSTS=$hosts
else
    # read conf parameters from command line
    echo "$(date +'%a %Y-%m-%d %H:%M:%S') INFO: no config file found in /etc/monitor_pi_net.conf, reading parameters from command line." | tee -a $TARGET_PATH/network_outage.log
    for i in "$@"
    do
    case $i in
	-c=*|--count=*)
	COUNT="${i#*=}"
	shift # past argument=value
        ;;
	-i=*|--intervall=*)
	INTERVALL="${i#*=}"
	shift # past argument=value
	;;
	-t=*|--timeout=*)
	TIMEOUT="${i#*=}"
	shift # past argument=value
	;;
	-i=*|--cycle=*)
	CYCLE="${i#*=}"
	shift # past argument=value
	;;
	-o=*|--template=*)
	TEMPLATE="${i#*=}"
	shift # past argument=value
	;;
	-h|--help)
	echo "Usage: monitor_net.sh -c=PINGS_PER_HOST -i=INTERVALL_SEC_BEFORE_FAIL -t=PING_TIMEOUT_SEC -i=PAUSE_BETWEEN_CYCLE_SEC {host}+"
	exit 0
	;;
	*)
        HOSTS="$i $HOSTS"
	;;
    esac
    done
fi

if [ "$HOSTS" == "" ]; then
    # no hosts provided. Hence exit
    echo "Usage: monitor_net.sh -c=PINGS_PER_HOST -i=INTERVALL_SEC_BEFORE_FAIL -t=PING_TIMEOUT_SEC -i=PAUSE_BETWEEN_CYCLE_SEC -o=TEMPLATE {host}+"
    echo "Help: monitor_net.sh -h"
    exit 0
fi 

# be sure that the previous run has terminated meanwhile
sleep 3

# mount ramdisk in order to save sdcard from permanent writing
# mount -t tmpfs -o size=10M none $TARGET_PATH

echo "$(date +'%a %Y-%m-%d %H:%M:%S') -------------------------------" | tee -a $TARGET_PATH/network_outage.log
echo "$(date +'%a %Y-%m-%d %H:%M:%S') starting with $COUNT pings per host, timeout $TIMEOUT s, retry $INTERVALL s, cycle $CYCLE s" | tee -a $TARGET_PATH/network_outage.log
touch $TARGET_PATH/ping.log

# Log shutdown message when the script is being killed
# trap clean_up SIGINT SIGTERM
# trap hangup SIGHUP
trap clean_up EXIT

# generate html before starting with pinging
cat $TMPL_PATH/$TEMPLATE > $TARGET_PATH/index.html
cat $TMPL_PATH/styles.css > $TARGET_PATH/styles.css
renderhtml

while true; do
    i=1
    status_str=""
    for myHost in $HOSTS
    do
        online="no"
        for c in `seq 1 $COUNT`
        do
            response=$(ping -W $TIMEOUT -c 1 $myHost)
            count=$(echo -e "$response" | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')
            time=$(echo -e "$response" | grep "bytes from" | awk -F ':' '{ print $2 }' | awk '{ print $3 }' | awk -F '=' '{ print $2}' | xargs)
            if [ "$count" == "1" ]; then
                online="yes"
		sleep 1
                break
            else
                echo -e "$(date +'%a %Y-%m-%d %H:%M:%S'):\n$response\n\n" >> $TARGET_PATH/ping.log
            fi
            if [ $c -ne $COUNT ]; then
                # sleep n seconds - in order to be able to react to SIGNALS
                for c in `seq 1 $INTERVALL`
                do
                    sleep 1
                done
            fi
        done

        if [ $online == "no" ]; then
          # host is down
          if [ "${status[i]}" != "down" ]; then
            echo "$(date +'%a %Y-%m-%d %H:%M:%S') down: $myHost" | tee -a $TARGET_PATH/network_outage.log
	    lastchange[$i]=`date +'%a %Y-%m-%d %H:%M:%S'`
          fi
          status[$i]="down"
        else
          # host is up
          if [ "${status[i]}" != "up" ]; then
            echo "$(date +'%a %Y-%m-%d %H:%M:%S')   up: $myHost" | tee -a $TARGET_PATH/network_outage.log
	    lastchange[$i]=`date +'%a %Y-%m-%d %H:%M:%S'`
          fi
          status[$i]="up"
        fi
        status_str[$i]=$(printf "%-20s %4s, $(date +'%H:%M:%S'), %-10s (since ${lastchange[i]})" "$myHost:" ${status[i]} "$time ms" )
        i=$((i+1))
    done
    renderhtml

    # sleep n seconds - in order to be able to react to SIGNALS
    for c in `seq 1 $CYCLE`
    do
        sleep 1
    done
done
