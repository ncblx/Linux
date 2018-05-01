#!/bin/bash

#
# Authenticates radius user in a NPS Windows Server 
# Nagios server has to be configured in NPS as a radius client
# Needs freeradius-utils
#

service="RADIUS"

# nagios plugins return values:
OK=0
WARNING=1
CRITICAL=2
UNKNOWN=3

# print usage information and exit
print_usage(){
    echo -e "\n" \
        "usage: $0 -h ipv4 -u user -p password -s secret \n" \
        "\n" \
        "-h host ipv4 \n" \
        "-u AD USER\n" \
        "-p password\n" \
        "-s radius secret\n" \
        "\n" && exit 1
}

# Loop through $@ to find flags
while getopts "u:p:s:h:" FLAG; do
    case "${FLAG}" in
        h) # host ip
           HOST="${OPTARG}" ;;
        u) # url to download
            USER="${OPTARG}" ;;
        p) # file to test
            PASSWORD="${OPTARG}" ;;
        s) # secret
            SECRET="${OPTARG}" ;;
        [:?]) # Print usage information
            print_usage;;
    esac
done


# check args


[[ ! $USER ]] && print_usage && exit $UNKNOWN
[[ ! $PASSWORD ]] && print_usage && exit $UNKNOWN
[[ ! $SECRET ]] && print_usage && exit $UNKNOWN


# Set status & return code:
status="OK" && return_code=$OK

check_result=$(echo "User-Name=$USER,User-Password=$PASSWORD" | radclient -4 $HOST auth $SECRET )

# Just for NPS 
#access=$(echo $check_result | grep -i Full-Access | wc -l)
# NPS and IAS message
# access=$(echo $check_result | grep -i Framed-User | wc -l)
# FreeRadius
access=$(echo $check_result | grep -i Access-Acept | wc -l)

[[ $access -ne 1 ]]  && status="CRITICAL" && return_code=$CRITICAL




#
# status
#
check_status=$(echo $service $status)

#
# Check info:
#
check_info="RADIUS OK"
[[ $access -ne 1 ]]  && check_info="Can't connect"


#
# perfdata
#
perfdata="radius=$access"


#
# Result
#
printf "%s %s | %s\n" "$check_status" "$check_info" "$perfdata"

#
# Return code
#
exit $return_code
