#This will be set up as a cron that will continually check for password changes to the FTP user and then change it for the respective Linux user.
for i in `mysql -e 'use sentora_core; select ac_user_vc from x_accounts' | grep -P "[a-z]*[A-Z]*[0-9]*" | grep -v ac_user_vc`;
do useridandpasswd=$(mysql -e 'use sentora_proftpd; select userid,passwd from ftpuser;'| grep $i);
userid=$(echo $useridandpasswd | awk {'print $1'}); pass=$(echo $useridandpasswd | awk {'print $2'});
echo "Resetting SFTP password for $userid"
useradd $userid
usermod -d /var/sentora/hostdata/$userid -G sftpusers $userid
echo "$userid:$pass" | chpasswd -m
done
