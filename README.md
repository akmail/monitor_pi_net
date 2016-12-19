monitor_pi_net
==============

SHORT DESCRIPTION
-----------------
This package was developed for Raspberry Pi (Raspbian OS) and provides you a service that monitors local network as well as internet hosts via ping. It also provides some basic information about Raspberry Pi software / current status (top, CUP temperature, open ports, unattended upgrades etc.). There is a log file report in plain text that shows the outages of hosts. Additionally a HTML report is generated (by default every 60 seconds). Contributor who like to make this script more generic and usable on other linux distributions are welcome.

The reason why I wrote this script was quite a sophisticated network (using Powerlan, WiFi, Switches etc.) setup at home resulting in some notable outages of internal and external connections. It has helped me lot to find where the weaknesses of the network setup are. Additionally I wanted an overview about status of my Respi(s).

DOWNLOAD AND INSTALL (TL;DR)
----------------------------
Following terminal commands will install the monitoring service with just one host monitoring, which is by default `google.de`. It automatically creates a service which is started after rebooting by default. The install script as well as the monitoring script itself must be run as root.

    wget https://github.com/akmail/monitor_pi_net/raw/master/monitor_pi_net_0.1.zip
    unzip monitor_pi_net_0.1.zip
    cd monitor_pi_net/
    chmod 775 install.sh
    sudo ./install.sh

It is safe to re-install the package by re-executing the `install.sh` script. It doesn't overwrite already existing HTML template / configuration.
In order to add hosts or IP addresses to you monitoring, just add them in the `/etc/monitor_pi_net.conf`, e.g. by following command:

    sudo nano /etc/monitor_pi_net.conf
    
SERVICE
-------
the install script creates a new monitoring service which automatically starts after reboot. In order to start the service execute the following command in the terminal:

    sudo /etc/init.d/monitor/pi/net start

to stop the service:

    sudo /etc/init.d/monitor/pi/net start

to get the current status:

    sudo /etc/init.d/monitor/pi/net status

to restart the service after changing of HTML template or configuration:

    sudo /etc/init.d/monitor/pi/net restart

CONFIGURATION FILE
------------------
`/etc/monitor_pi_net.conf`

COMMAND LINE PARAMETERS
-----------------------

HTML OUTPUT
-----------
everytime the script starts, it generates a ramdisk under `/media/ramdisk` (if not existing yet) in order to reduce write operations to the file system (which is a sd card on Raspberry Pi). Too many write operations reduce the lifetime of an sd card. hence it's worth to use a ramdisk for the reports that are generated quite often (every 60 seconds in the original configuration)
HTML report is generated in this ramdisk directory: `/media/ramdisk/index.html`
This page can be published on your webserver - please refer to your webserver documentation for further infromation.
