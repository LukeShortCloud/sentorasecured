#!/bin/sh
### SENTORA SECURED - Users - ss_users.sh
## Linux user creation

#This should be set up as a cron that will continually check for password changes to the FTP user and then change it for the respective Linux user.
for i in `mysql -e 'use sentora_core; select ac_user_vc from x_accounts' | grep -P "[a-z]*[A-Z]*[0-9]*" | grep -v ac_user_vc`;
do useridandpasswd=$(mysql -e 'use sentora_proftpd; select userid,passwd from ftpuser;'| grep $i);
userid=$(echo $useridandpasswd | awk {'print $1'}); pass=$(echo $useridandpasswd | awk {'print $2'});
echo "Resetting SFTP password for $userid"
useradd $userid 2&>1 /dev/null; groupadd $userid 2&>1 /dev/null;

#Set home directory for their hostdata folder, change their default group to themselves, and add them to the sftpusers for jailed SFTP access
usermod -d /var/sentora/hostdata/$userid -g $userid -a -G sftpusers $userid;
#MD5 password encryption is used
echo ''$userid':'$pass'' | chpasswd -m;
done


#Add custom vhosts lines to allow RUID2 to run Apache processes as the actual Linux user instead of "apache" or "nobody"
for userid in `cat /var/sentora/secured/trueuserdomains.txt | cut -d: -f2 | uniq`;
  do for domainname in `grep -P "^[0-9]*[0-9]*[0-9]*[0-9]*:${userid}" /var/sentora/secured/trueuserdomains.txt | cut -d: -f3`;
    do
mysql -e 'USE sentora_core; UPDATE x_vhosts SET vh_custom_tx="\
<IfModule !mod_ruid2.c>\
SuexecUserGroup '"$userid"' '"$userid"'\
</IfModule>\
<IfModule mod_ruid2.c>\
RMode config\
RUidGid '"$userid"' '"$userid"'\
RGroups apache\
</IfModule>" \
WHERE vh_name_vc="'"$domainname"'";'
done
done

#This is now run to rebuild the Apache vhost configuration at /etc/sentora/configs/apache/httpd-vhosts.conf
/usr/bin/php /etc/sentora/panel/bin/daemon.php 2&>1 /dev/null
