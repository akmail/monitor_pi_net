monitor_pi_net
==============

SHORT DESCRIPTION
-----------------
This package was developed for Raspberry Pi (Raspbian OS) and provides you a service that monitors local network as well as internet hosts via ping. It also provides some basic information about Raspberry Pi software / current status (top, CUP temperature, open ports, unattended upgrades etc.). There is a log file report in plain text that shows the outages of hosts. Additionally a HTML report is generated (by default every 60 seconds). Contributor who like to make this script more generic and usable on other linux distributions are welcome.

The reason why I wrote this script was quite a sophisticated network (using Powerlan, WiFi, Switches etc.) setup at home resulting in some notable outages of internal and external connections. It has helped me lot to find where the weaknesses of the network setup are. Additionally I wanted an overview about status of my Respi(s).

DOWNLOAD AND INSTALL
--------------------
    wget https://github.com/akmail/monitor_pi_net/raw/master/monitor_pi_net_0.1.zip
    unzip monitor_pi_net_0.1.zip
    cd monitor_pi_net/
    chmod 775 install.sh
    sudo ./install.sh

CONFIGURATION FILE
------------------
`/etc/monitor_pi_net.conf`

COMMAND LINE PARAMETERS
-----------------------

HTML OUTPUT
-----------
everytime the script starts, it generates a ramdisk under `/media/ramdisk` (if not existing yet)
HTML report is generated in a ramdisk directory: `/media/ramdisk/index.html`
This page can be published on your webserver - please refer to your webserver documentation for further infromation.
