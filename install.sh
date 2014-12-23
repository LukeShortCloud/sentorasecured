#Sentora Secured installer


#Backup the original sshd configuraiton
cp -a /etc/ssh/sshd_config /etc/ssh/sshd_config.$(date +%m-%d-%Y_%H_%M_%S)

#Get the SFTP jailed shell environment ready.
sed -i s/Subsystem/\#Subsystem/g /etc/ssh/sshd_config
echo -e "Subsystem\tsftp\tinternal-sftp\nAllowGroups sftpusers\nMatch Group sftpusers\n\tChrootDirectory /var/sentora/hostdata/u%/\n\tForceCommand internal-sftp\n\tX11Forwarding no\n\tAllowTcpForwarding no" >> /etc/ssh/sshd_config
groupadd sftpusers

service sshd reload


