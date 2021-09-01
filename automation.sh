#!/bin/bash
timestamp=$(date '+%d%m%Y-%H%M%S')
s3_bucket=upgrad-quazi
myname=quazi

#update sources
apt-get update

#upgrade exiting package
#apt-get upgrade -y

#check application install status
package_check_apache=`apt -qq list apache2 --installed |wc -l`

  if [ $package_check_apache == 0 ]
  then
        apt-get install apache2 -y
  fi

package_check_awscli=`apt -qq list awscli --installed |wc -l`

  if [ $package_check_awscli == 0 ]
  then
        apt-get install awscli -y
  fi

#check apache enabled or not
apache_check=`systemctl status apache2.service  | grep Active | awk '{ print $3 }'`

if [ $apache_check == "(dead)" ]
then
        systemctl enable apache2.service
fi

#check apache enabled or not
apache_check=`systemctl status apache2.service  | grep Active | awk '{ print $3 }'`

if [ $apache_check == "(dead)" ]
then
        systemctl enable apache2.service
fi

#check apache running status
if pgrep -x "apache2" >/dev/null
then
    echo "apache2 is running"
else
    systemctl start apache2
fi

#create tar file
cd /var/log/apache2 && tar -cvf /tmp/$myname-httpd-logs-$timestamp.tar *.log

if [ $? == 0 ]
then
        aws s3 cp /tmp/$myname-httpd-logs-$timestamp.tar s3://$s3_bucket/$myname-httpd-logs-$timestamp.tar
fi
