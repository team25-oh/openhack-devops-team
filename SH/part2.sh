#!/bin/bash

declare -i duration=1
declare hasUrl=""
declare endpoint
declare count=60

usage() {
    cat <<END
    polling.sh [-i] [-h] endpoint
    
    Report the health status of the endpoint
    -i: include Uri for the format
    -h: help
END
}

while getopts "ih" opt; do 
  case $opt in 
    i)
      hasUrl=true
      ;;
    h) 
      usage
      exit 0
      ;;
    \?)
     echo "Unknown option: -${OPTARG}" >&2
     exit 1
     ;;
  esac
done

shift $((OPTIND -1))

if [[ $1 ]]; then
  endpoint=$1
else
  echo "Please specify the endpoint."
  usage
  exit 1 
fi 


healthcheck() {
    declare url=$1
    result=$(curl -i $url 2>/dev/null | grep HTTP/2)
    if [[ -z $result ]]; then
	status="N/A"
    else
	status=${result:7:3}
	   fi
    echo $status
}

exit 1

# Check that the URL is up
while [[ true ]]; do
   status=`healthcheck $endpoint ` 

   timestamp=$(date "+%Y%m%d-%H%M%S")
   if [[ -z $hasUrl ]]; then
     echo "$timestamp | $status  | $count"
   else
     echo "$timestamp | $status | $endpoint  | $count" 
   fi
   if [[ $status -eq 200 ]]; then
       break;
   fi
       
   sleep $duration
   count=`expr $count - 1`
   if [[ $count -eq 0 ]]; then
       exit -1;
   fi

done
