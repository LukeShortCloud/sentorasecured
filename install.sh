#!/bin/sh
###SENTORA SECURED - Installer

#Set up Sentora Secured's installation directory
mkdir /var/sentora/secured/ /var/sentora/secured/uninstall/ /var/sentora/secured/old
chown root.root /var/sentora; chmod 770 /var/sentora/

#Sort out domains and their respective users
sh ./ss_domains.sh

#Fix insecure permissions
sh ./ss_permissions.sh

#Create Linux users
sh ./ss_users.sh

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
echo -e "Subsystem\tsftp\tinternal-sftp\nAllowGroups root sftpusers\nMatch Group sftpusers\n\tChrootDirectory %h\n\tForceCommand internal-sftp\n\tX11Forwarding no\n\tAllowTcpForwarding no"
service sshd restart


