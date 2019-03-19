#!/bin/bash                                                                                                                                                   
# Created by Syed Raza
# Objective:
## To find all the running instances in all regions running over x Hours or value threshold Hours defined in the CSV file.
#
#set -xv
while true
do
var=0
threshold=99999
whitelistfile=/tmp/ec2-whitelist.txt
# Whitelist file format name,hours
printf "NAME,REGION,INSTANCE-ID,DURATION\n" > /tmp/instances.csv

for i in $(aws ec2 describe-regions | jq -r .'Regions' | jq -r .[] | jq -r .'RegionName')
do
	echo "The Region Name is "$i""
	echo "Now Testing for Running instances in this regions"
	for inst in $(aws ec2 describe-instances --region "$i" --query 'Reservations[*].Instances[*].[InstanceId]' --filters Name=instance-state-name,Values=running --output json | jq -r .[] | jq -r .[] | jq -r .[])
		do 
			echo " This is the Running Instance "$inst""
			for dt0 in $(aws ec2 describe-instances --region "$i" --instance-id "$inst" | jq -r .'Reservations' | jq -r .[] | jq -r .'Instances' | jq -r .[] | jq -r .'LaunchTime')
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
				tag=$(aws ec2 describe-instances --region $i --instance-ids "$inst" --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text)
				a=$(grep -R "$tag" "$whitelistfile" | cut -d, -f 1 |  wc -l)
				limit=$(grep -R "$tag" "$whitelistfile" | cut -d, -f 2)
			if [ "$a" == "0" ] || [ "$hDiff" -ge "$limit" ] || [ "$hDiff" -ge "$threshold" ]; then
					var=1
					echo "We got a non white listed Instance running Name $tag ID $inst in Region $i for $hdiff"
					printf ""$tag","$i","$inst","$hDiff"\n" >> /tmp/instances.csv
				fi

			done
	done
done
if [ "$var" == "1" ]; 
then 
	echo "Need to send the email now ";
       	mutt -s "ALERT -- Unknown Instance Found -- Please look into attached CSV FILE" -a /tmp/instances.csv -- xyz@abc.com,abc@domain.com < .
fi
sleep 1800
done
