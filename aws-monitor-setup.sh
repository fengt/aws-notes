if [[ $(sudo crontab -l | egrep -v "^(#|$)" | grep -q 'mon-put-instance-data.pl'; echo $?) == 1 ]]
then
	sudo apt-get -y install libwww-perl libdatetime-perl
	curl https://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.2.zip -O
	unzip CloudWatchMonitoringScripts-1.2.2.zip && \
	rm CloudWatchMonitoringScripts-1.2.2.zip && \
	cd aws-scripts-mon
	cp awscreds.template awscreds.conf
cat <<EOT > awscreds.conf
AWSAccessKeyId=<YOUR KEYID>
AWSSecretKey=<YOUR SECRETKEY>
EOT
	./mon-put-instance-data.pl --mem-util --mem-used --mem-avail --disk-space-util --disk-space-used --disk-space-avail --disk-path=/
	sudo crontab -l > /home/ubuntu/crontab_jobs
  	sudo echo "*/5 * * * * /home/ubuntu/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-used --mem-avail --disk-space-util --disk-space-used --disk-space-avail --disk-path=/ --from-cron" >> /home/ubuntu/crontab_jobs
  	sudo crontab /home/ubuntu/crontab_jobs
  	sudo rm /home/ubuntu/crontab_jobs
fi