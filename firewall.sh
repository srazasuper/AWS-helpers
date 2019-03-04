#!/bin/bash
emails=xyz@abc.com,lmnbg@khg.com,etc@domain.com
while true;
do
var=0
printf "SECURITY-GROUPID,SECURITYGROUP-NAME,IP\n" > /tmp/firewall.csv

for i in $(aws ec2 describe-security-groups | jq -r '.' | jq -r '.SecurityGroups' | jq -r '[.]' | jq -r '.' | jq -r '.[0]' | jq -r '.[]' | jq -r '.GroupId')
 do

GN=`aws ec2 describe-security-groups --group-id $i | jq -r '.SecurityGroups' | jq -r '.[]' | jq -r '.GroupName'`
for ip in $(aws ec2 describe-security-groups --group-id $i | jq -r '.SecurityGroups' | jq -r '.[]' | jq -r '.IpPermissions' | jq -r '.[]' | jq -r '.IpRanges' | jq -r '.[]' | jq -r '.CidrIp'); 
do 
if [[ $ip =~ ^0.0.0 ]] || [[ $ip =~ ^::/0 ]]; then 
echo "Firewall is opened "$ip" found on SecurityGroup $i and name is "$GN""
printf "$i,$GN,$ip\n" >> /tmp/firewall.csv
var=1
fi
done
done
if [ "$var" == "1" ]; 
then 
	echo "Need to send the email now ";
       	mutt -s "ALERT -- Opened Ports Found -- Please look into attached CSV FILE" -a /tmp/firewall.csv -- $emails < .
fi
sleep 600
done
