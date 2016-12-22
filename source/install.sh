#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root, e.g. 'sudo ./install.sh'"
  exit 0
fi

echo "installing monitor_pi_net ..."

if [ -f "/etc/init.d/monitor_pi_net" ]; then
    echo "monitor_pi_net service exists, stopping ..."
    /etc/init.d/monitor_pi_net stop
fi

echo "copying monitor_pi_net.sh to /usr/bin ..."
chmod 775 monitor_pi_net.sh
cp monitor_pi_net.sh /usr/bin

echo "copying monitor_pi_net to /etc/init.d ..."
chmod 775 monitor_pi_net
cp monitor_pi_net /etc/init.d

if [ -f "/etc/monitor_pi_net.conf" ]; then
    echo "config file /etc/monitor_pi_net.conf already exists, skipping ..."
    echo "(example config can be found here: conf_example.conf)"
else
    echo "copying con_example.conf to /etc/monitor_pi_net.conf ..."
    cp conf_example.conf /etc/monitor_pi_net.conf
fi

echo "creating HTML template directory /var/lib/monitor_pi_net/ ..."
mkdir -p /var/lib/monitor_pi_net
if [ -f "/var/lib/monitor_pi_net/index.tmpl" ]; then
    echo "html template file /var/lib/monitor_pi_net/index.tmpl already exists, skipping ..."
else
    echo "copying index.tmpl to /var/lib/monitor_pi_net/ ..."
    cp index.tmpl /var/lib/monitor_pi_net/index.tmpl
fi
if [ -f "/var/lib/monitor_pi_net/styles.css" ]; then
    echo "CSS file /var/lib/monitor_pi_net/styles.css already exists, skipping ..."
else
    echo "copying styles.css to /var/lib/monitor_pi_net/ ..."
    cp styles.css /var/lib/monitor_pi_net/
fi

echo "creating log directory /var/log/monitor_pi_net/ ..."
mkdir -p /var/log/monitor_pi_net

echo "copying index.tmpl to /var/lib/monitor_pi_net/ ..."
cp index.tmpl /var/lib/monitor_pi_net/

echo "creating target report directoy /media/ramdisk/ ..."
mkdir -p /media/ramdisk

echo "enabling service monitor_pi_net ..."
update-rc.d monitor_pi_net defaults

echo "starting monitor_pi_net service ..."
/etc/init.d/monitor_pi_net start

echo "install completed."
exit 0
