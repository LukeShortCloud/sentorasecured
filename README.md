#Sentora Secured

*Version: v0.1 ALPHA

This software is designed to harden the security of the free and open source web hosting panel Sentora. The overall goal is to help strength permissions of various files, folders, and programs related to Sentora. This is built around the beta version of Sentora, v1.0.0. Use at your own risk! Development is still in progress.

###IN-DEPTH EXPLAINATION - What does this script actually do?
==============
* Disables FTP and replaces it entirely with jailed SFTP (which uses SSH protocols that most FTP clients support).
* Assuming there is an FTP account for a Sentora user with the same name as the Sentora username, it creates a Linux user for them.
* This Linux user is then added as a RUID2 user for Apache to run the processes as. SFTP will also use this user to help secure permissions (so not everyone has full access from the Apache user to edit other peoples files).
* Most of the default insecure permissions of Sentora are corrected.


