TODAY=$(date '+%Y-%m-%d')
DATETIME=$(date '+%Y-%m-%d_%H%M%S')
while IFS= read -r line; do
    IFS=',' read -ra array <<< "$line"
    instanceId=${array[0]}
    instanceIP=${array[1]}
    instanceName=${array[2]}
    instanceKey=${array[3]}
    echo $DATETIME."starting to setup monitor script of instance name: $instanceName"
    echo $DATETIME."starting to setup monitor script of instance: $line" >> $TODAY.monitor-script.log 2>&1
    ssh -oStrictHostKeyChecking=no -i $HOME/pems/$instanceKey.pem ubuntu@$instanceIP 'bash -s' < ./aws-monitor-setup.sh >> $TODAY.monitor-script.log 2>&1
    echo $DATETIME."finished setup monitor script." >> $TODAY.monitor-script.log 2>&1
    echo $DATETIME."finished setup monitor script."
done < instances.txt

echo $DATETIME."wait 30 seconds to ensure all metrics are successfully reported to CloudWatch......"
echo $DATETIME."wait 30 seconds to ensure all metrics are successfully reported to CloudWatch......" >> $TODAY.cloudwatch-alarm.log 2>&1
sleep 30s

while IFS= read -r line; do
    IFS=',' read -ra array <<< "$line"
    instanceId=${array[0]}
    instanceIP=${array[1]}
    instanceName=${array[2]}
	echo $DATETIME."starting to setup CloudWatch alarm of instance name: $instanceName"
    echo $DATETIME."starting to setup CloudWatch alarm of instance: $line" >> $TODAY.cloudwatch-alarm.log 2>&1
    aws2 cloudwatch put-metric-alarm --alarm-name awsec2-$instanceId-Disk-Space-Utilization --alarm-description "$instanceName ($instanceIP) - Alarm when Disk Space Utilization exceeds 80 percent" --metric-name DiskSpaceUtilization  --namespace System/Linux --statistic Average --period 300 --threshold 80 --comparison-operator GreaterThanThreshold --evaluation-periods 1 --alarm-actions arn:aws:sns:us-west-2:773317624911:DiskSpaceUtil_CloudWatch_Alarms_Topic --unit Percent --dimensions Name=InstanceId,Value=$instanceId Name=MountPath,Value=/ Name=Filesystem,Value=/dev/xvda1 > /dev/null
    echo $DATETIME."finished setup CloudWatch alarm." >> $TODAY.cloudwatch-alarm.log 2>&1
    echo $DATETIME."finished setup CloudWatch alarm."
done < instances.txt