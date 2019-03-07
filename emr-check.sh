#!/bin/bash
while true
do
var=0
printf "REGION,ClusterName\n" > /tmp/emr.csv
elist=/tmp/emr-whitelist.txt

for region in $(aws ec2 describe-regions | jq -r .'Regions' | jq -r .[] | jq -r .'RegionName')
do
	for running in $(aws emr list-clusters --region "$region" --cluster-states RUNNING | jq -r .'Clusters' | jq -r .[] | jq -r .'Name') 
	do
		a=`grep -R "$running" "$elist" | wc -l`
	       if [ "$a" == "0" ]; then
	       var=1
		clstr=$running	       
			printf ""$region","$clstr"\n" >> /tmp/emr.csv
	fi
	done
	for waiting in $(aws emr list-clusters  --region "$region" --cluster-states WAITING | jq -r .'Clusters' | jq -r .[] | jq -r .'Name')
	do
		b=`grep -R "$waiting" "$elist" | wc -l`
		if [ "$b" == "0" ]; then
			var=2
			clstw=$waiting
				printf ""$region","$clstw"\n" >> /tmp/emr.csv
		fi
	done
done
if [ "$var" != "0" ]; then
echo "Need to send the email now ";

echo "im var "$var""
echo "im b "$b""
echo "im a "$a""
echo "im  clstw "$clstw""
echo "im clstr "$clstr""
 mutt -s "ALERT -- Unknown EMR Found -- Please look into attached CSV FILE" -a /tmp/emr.csv -- xyz@abc.com,abc@xyz.com < .

fi
		
sleep 1800
done
