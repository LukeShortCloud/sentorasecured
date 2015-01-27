#!/bin/sh
### SENTORA SECURED - Users - ss_users.sh
## Linux user creation

for fulluserid in `cat /var/sentora/secured/trueuserdomains.txt | cut -d: -f1,2 | uniq`;
	do userid=$(echo $fulluserid | cut -d: -f1); username=$(echo $fulluserid | cut -d: -f2);
	
	## Delete already deleted FTP accounts from Sentora's database
	mysql -e 'use sentora_core; delete from x_ftpaccounts where ft_deleted_ts is not null;'
	
	## This looks for and deactivates all FTP accounts that do NOT have the same username as the Sentora user
	mysql -e 'use sentora_core; update x_ftpaccounts set ft_deleted_ts = "1" where ft_acc_fk = "'"$userid"'" and ft_user_vc != "'"$username"'" and ft_deleted_ts is NULL;';

	## If no FTP user exists for the Sentora user, it will created
	if [[ ! $(mysql -e 'use sentora_core; select * from x_ftpaccounts where ft_acc_fk = "'"$userid"'" and ft_user_vc = "'"$username"'";') ]]; 
		then randompass=$(openssl rand -base64 16);
		mysql -e 'use sentora_core; INSERT INTO x_ftpaccounts (ft_acc_fk,ft_user_vc,ft_directory_vc,ft_access_vc,ft_password_vc,ft_deleted_ts) VALUES("'"$userid"'","'"$username"'","/","RW","'"$randompass"'",NULL);';
	fi

done

#Create Linux/SFTP user if needed and reset their password
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

#This is now run to rebuild the Apache vhost configurations at /etc/sentora/configs/apache/httpd-vhosts.conf
mysql -e 'USE sentora_core; UPDATE x_settings SET so_value_tx="true" WHERE so_name_vc="apache_changed";'
/usr/bin/php /etc/sentora/panel/bin/daemon.php 2&>1 /dev/null
