#!/bin/sh
### SENTORA SECURED - CRON - ss_cron.sh
##This cron job will continually add in any new Linux/SFTP users, reset their FTP password to the current one, and correct permissions.

#Refresh the domain-user ownership file
sh /var/sentora/secured/ss_domains.sh

#Setup new jailed SFTP/Linux users and reset any new passwords
sh /var/sentora/secured/ss_users.sh

#Fix permissions
sh /var/sentora/secured/ss_permissions.sh
