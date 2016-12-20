monitor_pi_net
==============

SHORT DESCRIPTION
-----------------
This package was developed for Raspberry Pi (Raspbian OS) and provides you a service that monitors local network as well as internet hosts via ping. It also provides some basic information about Raspberry Pi software / current status (top, CUP temperature, open ports, unattended upgrades etc.). There is a log file report in plain text that shows the outages of hosts. Additionally a HTML report is generated (by default every 60 seconds). Contributors who like to make this script more generic and usable on other linux distributions are welcome.

The reason why I wrote this script was quite a sophisticated network (using Powerlan, WiFi, Switches etc.) setup at home resulting in some notable outages of internal and external connections. It has helped me lot to find where the weaknesses of the network setup are. Additionally I wanted an overview about status of my Raspi(s).

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
    
After the service has been started, an HTML report can be found here:`/media/ramdisk/index.html`

There is also a plain text log file: `/var/log/monitor_pi_net/network_outage.log`
   
SERVICE
-------
The install script creates a new monitoring service which automatically starts after reboot. In order to start the service execute the following command in the terminal:

    sudo /etc/init.d/monitor/pi/net start

to stop the service:

    sudo /etc/init.d/monitor/pi/net stop

to get the current status:

    sudo /etc/init.d/monitor/pi/net status

to restart the service after changing of HTML template or configuration:

    sudo /etc/init.d/monitor/pi/net restart

CONFIGURATION FILE
------------------
If the script detects a configuration file under `/etc/monitor_pi_net.conf`, it ignores command line paramters and uses this configuration file. Following you'll find a list of possible configuration parameters.

**pings_per_host (default value is 2 times)**
Max number of pings per host till it's considered as down. in case of value '2' both pings must fail in order to log the host as DOWN.

**pause_on_ping_fail (default value is 4 seconds)**
pause between pings if the previous ping failed. if *pings_per_host* is greater than 1, and the previous ping has failed, a pause is made till next ping on the same host is sent.

**ping_timeout (default value is 6 seconds)**
number of seconds a ping response should be waited for till it is considered an not reachable.

**pause_between_cycles (default value is 60 seconds)**
After all host status results are gathered (DOWN / UP) a report is generated. This configuration parameter defines how long to wait with re-testing again.

**hosts (cannot be empty)**
List of hosts or IP addresses to check separated by blank.

Example of a config file:

    # monitor_pi_net config file

    # max number of pings per host till. If all of them
    # fail the host is considerd as down
    pings_per_host=2

    # pause in seconds between pings on the same host - in case the previos failed
    # if the ping succeeds, no more pings are executed
    pause_on_ping_fail=4

    # seconds till ping is considered as failed
    ping_timeout=4

    # pause in seconds between cycles - e.g. 60 seconds
    pause_between_cycles=60

    # list of hosts to be monitored - separated by space
    hosts="google.com spiegel.de"

    
COMMAND LINE PARAMETERS
-----------------------
If there is no configuration file `/etc/monitor_pi_net.conf` you can specify some configuration parameters in the command line. Especially the list of hosts needs to be specified - otherwise the script will terminate. If desired the monitoring script can be used in batch mode by executing the script under `/usr/bin/monitor_pi_net.sh` with following parameters:

**-c=, --count (default value is 2 times)**
Max number of pings per host till it's considered as down. in case of value '2' both pings must fail in order to log the host as DOWN.

**-i, --intervall (default value is 4 seconds)**
pause between pings if the previous ping failed. if *pings_per_host* is greater than 1, and the previous ping has failed, a pause is made till next ping on the same host is sent.

**-t, --timeout (default value is 6 seconds)**
number of seconds a ping response should be waited for till it is considered an not reachable.

**-i, --cycle (default value is 60 seconds)**
After all host status results are gathered (DOWN / UP) a report is generated. This configuration parameter defines how long to wait with re-testing again.

**(hosts) (cannot be empty)**
List of hosts or IP addresses to check separated by blank without any option name.

**-o, --tmplate**
HTML template to be used for the report generation.

**-h, --help**
shows information about allowed command line parameters.

Example of batch mode execution (doesn't terminate, use `nohup ... ` for background execution):

    /usr/bin/monitor_pi_net.sh -c=2 -i=4 --timeout=6 --cycle=60 google.com youtube.com
    /usr/bin/monitor_pi_net.sh --template=/var/lib/monitor_pi_net/index.tmpl google.com youtube.com

HTML OUTPUT
-----------
Everytime the script starts, it generates a ramdisk under `/media/ramdisk` (if not existing yet) in order to reduce write operations to the file system (which is a sd card on Raspberry Pi). Too many write operations reduce the lifetime of an sd card. Hence it's worth to use a ramdisk for the reports that are generated quite often (every 60 seconds in the original configuration).
HTML report is generated in this ramdisk directory: `/media/ramdisk/index.html`.
This page can be published on your webserver - please refer to your webserver documentation for further infromation.

FILES REFERENCE
--------------------
- **install.sh** - installation script, can be re-executed. Stops (if existing), installs and starts the monitoring service.
- **conf_example.conf** - example configuration file, is copying during the first installation to `/etc/monitor_pi_net.conf`
- **styles.css** - CSS stylesheets for HTML report. During the first installation it's copied to `/var/lib/monitor_pi_net`. When a report is generated, a copy from `/var/lib/monitor_pi_net/styles.css`is being copied to `/media/ramdisk`
- **index.tmpl** - HTML template. During the first installation it's copied to `/var/lib/monitor_pi_net`. When a report is generated, `index.html`is being generated from `/var/lib/monitor_pi_net/index.tmpl` and copied to `/media/ramdisk`
- **monitor_pi_net.sh** - monitoring script, with every installation it's being copied to `/usr/bin/monitor_pi_net.sh`
- **monitor_pi_net** - service script, with every installation it's being copied to `/etc/init.d/monitor_pi_net`
- **/var/log/monitor_pi_net/notwork_outage.log** - plain text log file of the monitoring service
- **/var/log/monitor_pi_net/ping.log** - ping output of all failed pings - for further investigation
- **/media/ramdisk/index.html** - up-to-date report about raspi, current host status and recent host availability history. The data automatically updates, no browser refresh is necessary.
- **/media/ramdisk/styles.css** - link to `/var/lib/monitor_pi_net/styles.css`
- **/media/ramdisk/ping.log** - link to `/var/log/monitor_pi_net/ping.log`
- **/media/ramdisk/network_outage.log** - link to `/var/log/monitor_pi_net/network_outage.log`
- **/media/ramdisk/status.log** - contains curent availability status for all hosts, one line per host
- **/media/ramdisk/sysinfo.log** - some Raspi information such as top, netstat, CPU temperature, unattended upgrade logs etc.
