#!/bin/bash                                                                                                                                                   
# Created by Syed Raza
# Objective:
## To find all the running instances in all regions running over 10 Hours or value threshold Hours.
#
#set -xv
while true
do
var=0
threshold=10
whitelistfile=/tmp/ec2-whitelist.txt
printf "REGION,INSTANCE-ID,DURATION\n" > /tmp/instances.csv

for i in $(aws ec2 describe-regions | jq -r .'Regions' | jq -r .[] | jq -r .'RegionName')
do
	echo "The Region Name is "$i""
	echo "Now Testing for Running instances in this regions"
	for inst in $(aws ec2 describe-instances --region "$i" --query 'Reservations[*].Instances[*].[InstanceId]' --filters Name=instance-state-name,Values=running --output json | jq -r .[] | jq -r .[] | jq -r .[])
		do 
			echo " This is the Running Instance "$inst""
			for dt0 in $(aws ec2 describe-instances --instance-id "$inst" | jq -r .'Reservations' | jq -r .[] | jq -r .'Instances' | jq -r .[] | jq -r .'LaunchTime')
			do
				dt1=`date -d $dt0 +%Y-%m-%d\ %H:%M:%S`

				# Compute the seconds since epoch for date 1
				t1=`date --date="$dt1" +%s`

				# Date 2 : Current date
				dt2=`date +%Y-%m-%d\ %H:%M:%S`
				# Compute the seconds since epoch for date 2
				t2=`date --date="$dt2" +%s`

				# Compute the difference in dates in seconds
				let "tDiff=$t2-$t1"
				# Compute the approximate hour difference
				let "hDiff=$tDiff/3600"

				echo "Approx hour diff b/w $dt1 & $dt2 = $hDiff for Instance "$inst""
				echo "$hDiff"
				a=`grep -R "$inst" $whitelistfile | wc -l`
			if [ "$a" == "0" ]; then
				if [ "$hDiff" -ge "$threshold" ]; then
					var=1
					echo "We got a non white listed Instance running $inst in $i for $hdiff"
					printf ""$i","$inst","$hDiff"\n" >> /tmp/instances.csv
				fi
			fi

			done
	done
done
if [ "$var" == "1" ]; 
then 
	echo "Need to send the email now ";
       	mutt -s "ALERT -- 10+ Hours Running Instance Found -- Please look into attached CSV FILE" -a /tmp/instances.csv -- xyz@abc.com,abc@xyz.com < .
fi
sleep 1800
done
