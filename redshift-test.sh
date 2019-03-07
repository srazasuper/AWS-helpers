#!/bin/bash
while true
do
var=0
printf "REGION,ClusterName\n" > /tmp/redshift.csv
whitelist=/tmp/redshift-whitelist.txt
for region in $(aws ec2 describe-regions | jq -r .'Regions' | jq -r .[] | jq -r .'RegionName')
do

	for rs in $(aws redshift describe-clusters --region "$region" | jq -r .[] | jq -r .[] | jq -r .'Endpoint' | jq -r .'Address')
	do 
	count=`grep -R "^$rs" "$whitelist" | wc -l`

	if [ "$count" == "0" ]; then
		var=1
		echo "FOUND NON WHITELISTED CLUSTER $rs in $region and im going to report it like a kid"
		printf ""$region","$rs"\n" >> /tmp/redshift.csv


	fi

	done
done
if [ "$var" == "1" ];
	then
        echo "Need to send the email now ";
		
 mutt -s "ALERT -- Unknown Cluster Found -- Please look into attached CSV FILE" -a /tmp/redshift.csv  -- xyz@abc.com,abc@xyz.com < .
fi
sleep 1800
done
