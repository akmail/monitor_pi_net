# monitor_pi_net

SHORT DESCRIPTION
=================
This packege provides you a service that monitors local network as well as internet hosts via ping.
It also provides some basic information about Raspberry Pi software / current status
(top, CUP temperature, open ports, unattended upgrades etc.)
There is a log file report in plain text that shows the outages of hosts.
Additionally a HTML report is generated (by default every 60 seconds)

DOWNLOAD AND INSTALL
====================
 wget xxx
 unzip monitor_pi_net.zip
 cd monitor_pi_net/
 chmod 775 install.sh
 sudo ./install.sh

CONFIGURATION FILE
==================
/etc/monitor_pi_net.conf

COMMAND LINE PARAMETERS
=======================

HTML OUTPUT
===========
everytime the script starts, it generates a ramdisk under /media/ramdisk (if not existing yet)
HTML report is generated in a ramdisk directory: /media/ramdisk/index.html
This page can be published on your webserver - please refer to your webserver documentation for further infromation.
