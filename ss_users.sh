#/bin/bash
#SENTORA SECURED
#Linux user creation and password manager cron (and eventually systemd unit-timer)
#v0.0-2 ALPHA AND NOT WORKING
# What does this script do?
# 	-Disables the proftpd service
#	-Uses FTP credentials from a user that has the same name as the Sentora user to create a Linux user
#		--Preferably, you should only allow 1 FTP account in your packages
#	-Instead of using jailed SSH, only allow jailed SFTP access to their home directory
#	-This should be run as a cron to check if the password has been changed or if a new Linux user needs to be created
#	-Using the Apache RUID2 module, this script will edit Apache's configuration to allow only the execution of processes from these Linux users
#		--This removes the need for insecure permissions of "apache.apache" and "777" in a persons public_html/ folder.
# Tested on CentOS 6 x64. 

# Find all FTP accounts named the same as the Sentora user along with the FTP plain-text password. 
# User variable = userid , Password variable = pass
for i in `mysql -e 'use sentora_core; select ac_user_vc from x_accounts' | grep -P "[a-z]*[A-Z]*[0-9]*" | grep -v ac_user_vc`; 
	#Grab the credentials
	do useridandpasswd=$(mysql -e 'use sentora_proftpd; select userid,passwd from ftpuser;' | grep $i); 
	
	#Sort out the user and pass
	#FIXME - add verify to make sure the FTP username does not belong to another Sentora username
	userid=$(echo $useridandpasswd | awk {'print $1'}); pass=$(echo $useridandpasswd | awk {'print $2'}); 
	echo "$userid $pass"
	#Convert the password into MD5 encryption
	md5pass=$(mysql -e "select md5('"$pass"');" | grep -v md5)
	
	#See if the Linux user already exists
	usercheck=$(finger $userid 2>&1 | grep -c "no such user")
	if [[ $usercheck -ne 0 ]]; 
		then echo "A Linux user needs to be created for $i";
		
		#Setup jailed SFTP
		useradd $userid; usermod -d /$userid -s /sbin/nologin $userid
		echo "$userid:$pass" | chpasswd -m
		
		

		
		
	elif [[ $usercheck -eq 0 ]]; 
		then echo "The user $i exists";
		passcheck=$(grep $i /etc/shadow | cut -d: -f2)
		#Make sure the current password is being used
		echo "Are the FTP and Linux passwords the same for $userid'?'" 
		if [[ $(grep -c $md5pass /etc/shadow) -gt 0 ]]
			then echo "Yes"
			else echo "No"
		fi

		#FIXME - finish the check
		
		#...otherwise update to the new password
	fi;
	
	
	
	#FIXME - add in Apache RUID2 user configuration
done

service sshd reload
