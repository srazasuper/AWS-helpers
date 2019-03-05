#!/bin/bash                                                                                                                                                   

#cur=`date -u +"%Y-%m-%dT%H:%M:%S.%3NZ"`
dt0=`aws ec2 describe-instances --instance-id i-058fc36dd69a2ba3c | jq -r .'Reservations' | jq -r .[] | jq -r .'Instances' | jq -r .[] | jq -r .'LaunchTime'`
echo $dt0
dt1=`date -d $dt0 +%Y-%m-%d\ %H:%M:%S`
echo $dt1








# Date 1
#dt1="2019-03-05 17:50:49"
#dt1="2019-03-05 11:11:11"
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

echo "Approx hour diff b/w $dt1 & $dt2 = $hDiff"
