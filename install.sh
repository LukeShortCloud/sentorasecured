#!/bin/sh
###SENTORA SECURED - Installer

#Set up Sentora Secured's installation directory
mkdir /var/sentora/secured/ /var/sentora/secured/uninstall/
chown root.root /var/sentora; chmod 770 /var/sentora/

#Sort out domains and their respective users
sh ./ss_domains.sh

#Create Linux users
sh ./ss_users.sh

#Fix insecure permissions
sh ./ss_permissions.sh

#Backup the original sshd configuraiton
cp -a /etc/ssh/sshd_config /etc/ssh/sshd_config.$(date +%m-%d-%Y_%H_%M_%S)
echo "Your original sshd configuration has been saved to $(\ls -t /etc/ssh/ | head -n 2 | grep -P [0-9])"

#Get the SFTP jailed shell environment ready.
sed -i s/Subsystem/\#Subsystem/g /etc/ssh/sshd_config
echo -e "Subsystem\tsftp\tinternal-sftp\nAllowGroups root sftpusers\nMatch Group sftpusers\n\tChrootDirectory %h\n\tForceCommand internal-sftp\n\tX11Forwarding no\n\tAllowTcpForwarding no" >> /etc/ssh/sshd_config
groupadd sftpusers

service sshd restart


