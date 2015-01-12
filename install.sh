#!/bin/sh
###SENTORA SECURED - Installer
##v0.1-2

#Set up Sentora Secured's installation directory
mkdir /var/sentora/secured/ /var/sentora/secured/uninstall/ /var/sentora/secured/old 2&>1 /dev/null
chown root.root /var/sentora; chmod 770 /var/sentora/

#Disable Pro-FTPD. SSH will be handling SFTP.
service proftpd stop; chkconfig proftpd off >> /dev/null 2>; systemctl disable proftpd >> /dev/null 2>;

#Backup the original Sentora MySQL database 
mysqldump -f sentora_core > /var/sentora/secured/uninstall/sentora_core.sql

#Sort out domains and their respective users
sh ./ss_domains.sh

#Create Linux users
sh ./ss_users.sh

#Fix insecure permissions
sh ./ss_permissions.sh

#Backup the original sshd configuraiton
cp -a /etc/ssh/sshd_config /var/sentora/secured/uninstall/sshd_config
echo "Your original sshd configuration has been saved to /var/sentora/secured/uninstall/sshd_config"

##Get the SFTP jailed shell environment ready.

#Disable/comment-out possible conflicting entries in the SSH configuration file
sed -i s/Subsystem/\#Subsystem/g /etc/ssh/sshd_config
sed -i s/AllowUsers/\#AllowUsers/g /etc/ssh/sshd_config
sed -i s/AllowGroups/\#AllowGroups/g /etc/ssh/sshd_config
sed -i s/Match/\#Match/g /etc/ssh/sshd_config
sed -i s/ChrootDirectory/\#ChrootDirectory/g /etc/ssh/sshd_config
sed -i s/ForceCommand/\#ForceCommand/g /etc/ssh/sshd_config
sed -i s/X11Forwarding/\#X11Forwarding/g /etc/ssh/sshd_config
sed -i s/AllowTcpForwarding/\#AllowTcpForwarding/g /etc/ssh/sshd_config

#Enable jailed SFTP 
echo -e "Subsystem\tsftp\tinternal-sftp\nAllowGroups root sftpusers\nMatch Group sftpusers\n\tChrootDirectory %h\n\tForceCommand internal-sftp\n\tX11Forwarding no\n\tAllowTcpForwarding no" >> /etc/ssh/sshd_config;
service sshd restart


