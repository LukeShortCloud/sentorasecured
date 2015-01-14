#!/bin/sh
### SENTORA SECURED - Uninstaller - uninstall.sh
## This will remove the Sentora Secured program and revert most of Sentora's settings back to normal.

##Restoring original permissions
apacheUser=$(grep -P ^User /etc/httpd/conf/httpd.conf | cut -d" " -f2)
apacheGroup=$(grep -P ^Group /etc/httpd/conf/httpd.conf | cut -d" " -f2)
find /var/sentora/hostdata/ -name "*" -exec chown $apacheUser.$apacheGroup {} \;
find /etc/sentora -type f -exec chmod 755 {} \;
find /etc/sentora -type d -exec chmod 755 {} \;
chmod 6755 /etc/sentora/panel/bin/zsudo;

##Removing custom RUID2 vhost entries 
for userid in `cat /var/sentora/secured/trueuserdomains.txt | cut -d: -f2 | uniq`;
  do for domainname in `grep -P "^[0-9]*[0-9]*[0-9]*[0-9]*:${userid}" /var/sentora/secured/trueuserdomains.txt | cut -d: -f3`;
    do mysql -e 'USE sentora_core; UPDATE x_vhosts SET vh_custom_tx=NULL;'
	done
done

##Removing the cron
echo -e "$(crontab -l | grep -v "/var/sentora/secured")" | crontab -
