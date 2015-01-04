#STUB
#For jailed SFTP access to work, folders leading up to their home directory /var/sentora/hostdata/USER/ MUST be owned by the user root and ONLY be writable by the user root.
#/var/sentora = 755 root.apache
#/var/sentora/hostdata = 755 root.apache
#/var/sentora/hostdata/USER = 750 root.sftpusers
#/var/sentora/hostdata/USER/DOMAIN_COM = 700 USER.sftpusers
