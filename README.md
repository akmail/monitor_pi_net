monitor_pi_net
==============

SHORT DESCRIPTION
-----------------
This package was developed for **Raspberry Pi (Raspbian OS)** and provides you a service that **monitors local network as well as internet hosts via ping**. It also provides some basic **information about Raspberry Pi** software / current status (top, CUP temperature, open ports, unattended upgrades etc.). There is a log file report in plain text that shows the outages of hosts. Additionally a HTML report is generated (by default every 60 seconds). Meanwhile it runs on all Debian-based systems. Contributors who like to make this script even more generic and usable on other linux distributions are welcome.

The reason why I wrote this script was quite a sophisticated network (using Powerlan, WiFi, Switches etc.) setup at home resulting in some notable outages of internal and external connections. It has helped me lot to find where the weaknesses of the network setup are. Additionally I wanted an overview about status of my Raspi(s).

![Monitoring Example](https://raw.githubusercontent.com/akmail/monitor_pi_net/master/monitor_pi_net.png)

DOWNLOAD AND INSTALL (TL;DR)
----------------------------
Following terminal commands will install the monitoring service with example host(s) monitoring. It automatically creates a service which is started after rebooting by default. The install script as well as the monitoring script itself must be run as root.

**Install using git:**

    sudo apt-get install git dialog
    git clone https://github.com/akmail/monitor_pi_net
    cd monitor_pi_net/source
    chmod 775 install.sh
    sudo ./install.sh

**Install using wget:**

    wget --output-document=monitor_pi_net.zip https://github.com/akmail/monitor_pi_net/archive/master.zip
    unzip -o monitor_pi_net.zip
    cd monitor_pi_net-master/source
    chmod 775 install.sh
    sudo ./install.sh

It is safe to re-install the package by re-executing the `install.sh` script. It doesn't overwrite already existing HTML template / configuration.  
In order to add hosts or IP addresses to you monitoring, just add them in the `/etc/monitor_pi_net.conf`, e.g. by following commands:

    sudo nano /etc/monitor_pi_net.conf
    sudo /etc/init.d/monitor_pi_net restart
    
After the service has been started, an HTML report can be found here:`/var/log/monitor_pi_net/index.html`  
or (if apache is installed) via browser: `http://<your_raspi_ip_address>/monitor_pi_net/index.html`  
There is also a plain text log file: `/var/log/monitor_pi_net/network_outage.log`

SERVICE
-------
The install script creates a new monitoring service which automatically starts after reboot. In order to start the service execute the following command in the terminal:

    sudo /etc/init.d/monitor_pi_net start

to stop the service:

    sudo /etc/init.d/monitor_pi_net stop

to get the current status:

    sudo /etc/init.d/monitor_pi_net status

to restart the service after changing of HTML template or configuration:

    sudo /etc/init.d/monitor_pi_net restart

to reload HTML / CSS templates (doesn't reload the configuration):

    sudo /etc/init.d/monitor_pi_net restart
    
CONFIGURATION FILE
------------------
If the script detects a configuration file under `/etc/monitor_pi_net.conf`, it ignores command line paramters and uses this configuration file. Following you'll find a list of possible configuration parameters.

**pings_per_host (default value is 2 times)**  
Max number of pings per host till it's considered as down. in case of value '2' both pings must fail in order to log the host as DOWN.

**pause_on_ping_fail (default value is 4 seconds)**  
pause between pings if the previous ping failed. if *pings_per_host* is greater than 1, and the previous ping has failed, a pause is made till next ping on the same host is sent.

**ping_timeout (default value is 6 seconds)**  
number of seconds a ping response should be waited for till a single ping try is considered as failed.

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
If there is no configuration file `/etc/monitor_pi_net.conf` you can specify some configuration parameters in the command line and use the monitoring script `monitor_pi_net.sh` in standalone mode. Especially the list of hosts needs to be specified - otherwise the script will terminate. If desired the monitoring script can be used in batch mode by executing the script under `/usr/bin/monitor_pi_net.sh` with following parameters:

**-c, --count (default value is 2 times)**  
Max number of pings per host till it's considered as down. in case of value '2' both pings must fail in order to log the host as DOWN.

**-i, --intervall (default value is 4 seconds)**  
pause between pings if the previous ping has failed. if *pings_per_host* is greater than 1, and the previous ping has failed, a pause is made till next ping on the same host is sent.

**-t, --timeout (default value is 6 seconds)**  
number of seconds a single ping response should be waited for till it is considered an lost.

**-i, --cycle (default value is 60 seconds)**  
After all host status results are gathered (DOWN / UP) a report is generated. This configuration parameter defines how long to wait with re-testing again.

**-o, --template**  
HTML template to be used for the report generation. Only file name needs to be specified. it has to be located under `/var/lib/monitor_pi_net/`.

**-h, --help**  
shows information about allowed command line parameters, doesn't start any monioring.

**{hosts}**  
List of hosts or IP addresses to check, separated by blank - without any option name. If no hosts are specified, the monitoring script terminates immediately.

Here an example of batch mode execution (it doesn't terminate, but keeps monitoring in a loop, use `nohup ... &` for background execution):

    /usr/bin/monitor_pi_net.sh -c=2 -i=4 --timeout=6 --cycle=60 google.com 192.168.1.1
    /usr/bin/monitor_pi_net.sh --template=/var/lib/monitor_pi_net/index.tmpl google.com youtube.com

HTML OUTPUT
-----------
HTML report is generated in this directory: `/var/log/monitor_pi_net/index.html`.
This page can be published on your webserver - please refer to your webserver documentation for further infromation.

ADD REPORT TO APACHE WEBSERVER
------------------------------
The install script automatically adds the monitoring page to existing apache instance if it detects it on the system. In order to manually add the report to the existing apache webserver that is running on your Raspberry PI, run following command:

    cd /var/www/html
    sudo mkdir monitor_pi_net
    sudo chmod 775 monitor_pi_net
    sudo ln -s /var/log/monitor_pi_net monitor_pi_net

the report can be reached via follwing URL: `http://<your_raspi_address>/monitor_pi_net/index.html`

FILES REFERENCE
--------------------------------------------------------------------------------------------------------------------
| File                                           | Description                                                     |
| ---------------------------------------------- | --------------------------------------------------------------- |
| **install.sh**                                 | installation script, can be re-executed. Stops (if existing), installs and starts the monitoring service.
| **conf_example.conf**                          | example configuration file, is copied during the first installation to `/etc/monitor_pi_net.conf`
| **styles.css**                                 | CSS stylesheets for HTML report. During the first installation it's copied to `/var/lib/monitor_pi_net`. When a report is generated, a copy from `/var/lib/monitor_pi_net/styles.css`is being copied to `/var/log/monitor_pi_net`
| **index.tmpl**                                 | HTML template. During the first installation it's copied to `/var/lib/monitor_pi_net`. When a report is generated, `index.html`is being generated from `/var/lib/monitor_pi_net/index.tmpl` and copied to `/var/log/monitor_pi_net`
| **monitor_pi_net.sh**                          | monitoring script, with every installation it's being copied to `/usr/bin/monitor_pi_net.sh`
| **monitor_pi_net**                             | service script, with every installation it's being copied to `/etc/init.d/monitor_pi_net`
| **/var/log/monitor_pi_net/network_outage.log** | plain text log file of the monitoring service
| **/var/log/monitor_pi_net/ping.log**           | ping output of all failed pings - for further investigation
| **/var/log/monitor_pi_net/index.html**                  | up-to-date report about raspi, current host status and recent host availability history. The data automatically updates, no browser refresh is necessary.
| **/var/log/monitor_pi_net/styles.css**                  | copy of `/var/lib/monitor_pi_net/styles.css`
| **/var/log/monitor_pi_net/ping.log**                    | recent entries from `/var/log/monitor_pi_net/ping.log`
| **/var/log/monitor_pi_net/network_outage.log**          | recent entries from `/var/log/monitor_pi_net/network_outage.log`
| **/var/log/monitor_pi_net/status.log**                  | contains curent availability status for all hosts, one line per host
| **/var/log/monitor_pi_net/sysinfo.log**                 | some Raspi information such as top, netstat, CPU temperature, unattended upgrade logs etc.
