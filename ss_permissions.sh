#!/bin/sh
### SENTORA SECURED - PERMISSIONS - ss_permissions.sh
## This is ran as part of the first time installer to correct vulnerable permissions

#Back up original permission values
if [[ -f /var/sentora/secured/uninstall/OriginalPermissions.txt ]];
  then mv /var/sentora/secured/uninstall/OriginalPermissions.txt /var/sentora/secured/uninstall/OriginalPermissions.txt$(date +%m-%d-%Y_%H-%M-%S);
fi
> /tmp/perms.build;
find /var/sentora/ -name "*" >> /tmp/perms.build;
find /etc/sentora/ -name "*" >> /tmp/perms.build;
for i in `cat /tmp/perms.build`; do echo "$(stat ${i} 2> /dev/null | grep -Po "(-|d|l)(-|r|w|x)(r|w|x)(-|r|w|x)*"):${i} " >> /var/sentora/secured/uninstall/OriginalPermissions.txt; done


#For jailed SFTP access to work, folders leading up to their home directory /var/sentora/hostdata/USER/ MUST be owned by the user root and ONLY be writable by the user root.
chmod 755 /var/sentora; chown root.apache /var/sentora;
chmod 755 /var/sentora/hostdata; chown root.apache /var/sentora/hostdata;

#Correct user permissions for RUID2 so their processes run as the actual Linux user
for userid in `cat /var/sentora/secured/trueuserdomains.txt | cut -d: -f2 | uniq`;
  do find /var/sentora/hostdata/${userid}/ -name "*" -not -user ${userid} -exec chown ${userid}.${userid} {} \;
  chown root.${userid} /var/sentora/hostdata/${userid}/
  chmod 770 /var/sentora/hostdata/${userid}/;
done

#General Sentora permissions fix
find /etc/sentora -type f -exec chmod 555 {} \;
find /etc/sentora -type d -exec chmod 555 {} \;
chmod 6755 /etc/sentora/panel/bin/zsudo;
chown root: /root/passwords.txt; chmod 660 /root/passwords.txt;
chown -R root: /var/sentora/secured/; chmod -R 750 /var/sentora/secured;
