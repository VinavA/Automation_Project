#!/bin/bash
my_name="vinav"
s3_bucket="upgrad-vinav"

sudo apt -y update

if [ "dpkg --get-selections | grep apache2 | awk 'NR==1{print $1}' != apache2" ]; then
    sudo apt-get -y install apache2
fi

apacheRunning=`systemctl status apache2 | grep 'active (running)' | wc -l`
if [ $apacheRunning -ne 1 ]; then
    sudo service apache2 start
fi

apacheEnabled=`systemctl status apache2 | grep 'apache2.service; enabled' | wc -l`
if [ $apacheEnabled -ne 1 ]; then
    sudo systemctl enable apache2
fi

datetimestamp=$(date '+%m%d%Y-%H%M%S')
filename=$my_name-httpd-logs-$datetimestamp.tar
cd /var/log/apache2/
sudo tar -cvf /tmp/$filename *.log
cd ~
aws s3 cp /tmp/$filename s3://${s3_bucket}/$filename

fileSize=`ls /tmp/$tarfile -sh | awk {'print $1'}`
if [ ! -f /var/www/html/inventory.html ]; then
    touch /var/www/html/inventory.html
	echo -e '\tLog Type\tDate Created\tType\tSize' >> /var/www/html/inventory.html
fi
echo -e '\thttpd-logs\t'$datetime'\ttar\t'$fileSize >> /var/www/html/inventory.html

if [ ! -f /etc/cron.d/automation ]; then
    touch /etc/cron.d/automation
    echo '* * * * * root /root/Automation_Project/automation.sh' >> /etc/cron.d/automation
fi
