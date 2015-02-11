#Sentora Secured

* Version: v0.3 ALPHA

This software is designed to harden the security of the free and open source web hosting panel Sentora. The overall goal is to help strength permissions of various files, folders, and programs related to Sentora. This is built around the beta version of Sentora, v1.0.0, and tested on Red Hat Enterprise Linux based systems (including CentOS). Use at your own risk! Development is still in progress.

For installing, just run the "install.sh" script:
```bash
wget https://github.com/ekultails/sentorasecured/archive/master.zip; unzip master.zip; cd ./sentorasecured-master/; sh install.sh
```
Or to uninstall run the "uninstall.sh":
```bash
wget https://github.com/ekultails/sentorasecured/archive/master.zip; unzip master.zip; cd ./sentorasecured-master/; sh uninstall.sh
```

###IN-DEPTH EXPLAINATION - What does this script actually do?
==============
* Disables FTP and replaces it entirely with jailed SFTP (which uses SSH protocols that most FTP clients support).
* If there is an FTP account for a Sentora user with the same name as the Sentora username, it creates a Linux user for them based on that FTP account's password.
* If there is no FTP account tied to the Sentora user, one is created with a random password.
* This Linux user is then added as a RUID2 user for Apache to run the processes as. SFTP will also use this user to help secure permissions (so not everyone has full access from the Apache user to edit other peoples files).
* Most of the default insecure permissions of Sentora are corrected.


### How do I use it?
Sentora Secured will replace your FTP module with a slightly modified SFTP module. You can manage your SFTP account password there. It can take up to 1 hour before new passwords are updated and any possibly new Sentora users are updated to have an SFTP account. If you wish to process a manual update, simply run this command as root:
```bash
sh /var/sentora/secured/ss_users.sh
```



