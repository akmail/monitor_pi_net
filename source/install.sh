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

echo "creating target report directory /media/monitor_pi_net/ and mounting it as a ramdisk in /etc/fstab ..."
mkdir -p /media/monitor_pi_net
chmod a+rwx /media/monitor_pi_net
if [ ! -f "/etc/fstab.bak_monitor_pi_net" ]; then
    sudo cp /etc/fstab /etc/fstab.bak_monitor_pi_net
fi
grep monitor_pi_net /etc/fstab || sudo echo "tmpfs     /media/monitor_pi_net   tmpfs   size=2M,noatime   0     0" >> /etc/fstab
sudo mount -a

if [ -d "/var/www/html" ]; then
    echo "found /var/www/html, creating link to /media/monitor_pi_net ..."
    ln -s /media/monitor_pi_net /var/www/html/monitor_pi_net
else
    echo "no /var/www/html directory found. Please add html report /media/monitor_pi_net manually to your web server!"
fi

echo "enabling service monitor_pi_net ..."
update-rc.d monitor_pi_net defaults

echo "starting monitor_pi_net service ..."
/etc/init.d/monitor_pi_net start

echo "install completed."
exit 0
