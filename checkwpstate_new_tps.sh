#!/bin/bash
#
# WAP Gateway Check Write statistics script

#
# input parameters:
# $1 - wapproxy ID
# $2 - WAPINSTBASE value
# $3 - time delay between 2 calls script

# Define variables
WAPUSER=`/bin/id | sed 's/uid=[0-9]*(\([^ )]*\)) gid=.*/\1/'`
PROXYID=${1:-"1"}
WAPINSTBASE=${2:-"$HOME/wgateway"}
TIME_DELAY=${3:-"60"}
SRVID=`/usr/bin/hostname`
WP_NAMES="`$WAPINSTBASE/bin/wpcontrol -n$PROXYID -l`"
WP_OUTPUT="`$WAPINSTBASE/bin/wpcontrol -p -n$PROXYID`"

#generate statistics filename
FILENAME=$WAPINSTBASE/wpstat/wpstat_${SRVID}_${PROXYID}_`date '+%Y%m%d'`.log

PROXYPIDS=`ps -u $WAPUSER | grep "wapproxy" | awk '{ print $1 }'`
RESULT_LINE="`date '+%Y-%m-%d %H:%M:%S'` "$SRVID" "$PROXYID

# for all WAP GW PID-�� wap gw
for WPPID in $PROXYPIDS
do

    CHECKPROXY=`ps -p $WPPID -o args | awk '{ print $2 }'`
    if [ -n "$CHECKPROXY" ];
    then
        if [ "-r$PROXYID" = $CHECKPROXY ];

        then

#  try to find out instanse mane

       NAMES_COUNT=`echo "${WP_NAMES}" | grep -c "<"`

       if [ "$NAMES_COUNT" -eq 1 ];
       then
       INSTANSE_NAME=`echo "${WP_NAMES}" | grep "<" | cut -d "<" -f 2 | cut -d ">" -f 1`
       COMM_STAT=`$WAPINSTBASE/bin/wpcontrol -sc -n$PROXYID -i $INSTANSE_NAME`
       HTTP_REQ_CUR=`echo "$COMM_STAT" | grep "Total number of HTTP server requests" | cut -d "=" -f 2`

         STAT_FILE=$WAPINSTBASE/wpstat/ID_${PROXYID}_${INSTANSE_NAME}.stat

         # if file exit
         if [ -s $STAT_FILE ]
         then
         HTTP_REQ_OLD=`cat $STAT_FILE`
         fi
         # if value have been readed and it less than curent value
         if [[ -n "$HTTP_REQ_OLD" && $HTTP_REQ_OLD -lt $HTTP_REQ_CUR ]];
          then
          REAL_TPS=`expr $HTTP_REQ_CUR - $HTTP_REQ_OLD`
          REAL_TPS_1=`expr $REAL_TPS \/ $TIME_DELAY`
          REAL_TPS_2=`expr $REAL_TPS \% $TIME_DELAY`
          REAL_TPS=${REAL_TPS_1}.${REAL_TPS_2}

          else
          #  if value more that current, so WAP GW has been restarted. ����饥 ���祭�� ��襬 � 䠩�, � ॠ����� TPS �����塞
          REAL_TPS=0.0
         fi

         # write current value to file
         echo $HTTP_REQ_CUR  > $STAT_FILE

       elif [ "$NAMES_COUNT" -eq 2 ]
       then
        INSTANSE_NAME_CO=`echo "${WP_NAMES}" | grep "<" | head -n 1 | cut -d "<" -f 2 | cut -d ">" -f 1`
        INSTANSE_NAME_CL=`echo "${WP_NAMES}" | grep "<" | tail -1 | cut -d "<" -f 2 | cut -d ">" -f 1`
        COMM_STAT_CO=`$WAPINSTBASE/bin/wpcontrol -sc -n$PROXYID -i $INSTANSE_NAME_CO`
        WAP_CO_REQ_CUR=`echo "$COMM_STAT_CO" | grep "Total number of WAP requests" | awk '{print $7}'`
        COMM_STAT_CL=`$WAPINSTBASE/bin/wpcontrol -sc -n$PROXYID -i $INSTANSE_NAME_CL`
        WAP_CL_REQ_CUR=`echo "$COMM_STAT_CL" | grep "Total number of WAP requests" | awk '{print $7}'`
       # name names

         STAT_FILE_CO=$WAPINSTBASE/wpstat/ID_${PROXYID}_${INSTANSE_NAME_CO}.stat
         STAT_FILE_CL=$WAPINSTBASE/wpstat/ID_${PROXYID}_${INSTANSE_NAME_CL}.stat

        if [[ -s $STAT_FILE_CO && -s $STAT_FILE_CL ]]
        then
        WAP_CO_REQ_OLD=`cat $STAT_FILE_CO`
        WAP_CL_REQ_OLD=`cat $STAT_FILE_CL`
        else
        echo $STAT_FILE_CO and $STAT_FILE_CL files don\'t exist.
        fi

        if [[ -n "$WAP_CO_REQ_OLD" &&  $WAP_CO_REQ_OLD -lt $WAP_CO_REQ_CUR ]]
        then
        WAP_CO_REQ=`expr $WAP_CO_REQ_CUR - $WAP_CO_REQ_OLD`
        else
        WAP_CO_REQ=0
        fi

        if [[ -n "$WAP_CL_REQ_OLD" &&  $WAP_CL_REQ_OLD -lt $WAP_CL_REQ_CUR ]]
        then
        WAP_CL_REQ=`expr $WAP_CL_REQ_CUR - $WAP_CL_REQ_OLD`
        else
        WAP_CL_REQ=0
        fi

        REAL_TPS=`expr $WAP_CL_REQ + $WAP_CO_REQ`
        REAL_TPS_1=`expr $REAL_TPS \/ $TIME_DELAY`
        REAL_TPS_2=`expr $REAL_TPS \% $TIME_DELAY`
        REAL_TPS=${REAL_TPS_1}.${REAL_TPS_2}

        echo $WAP_CO_REQ_CUR > $STAT_FILE_CO
        echo $WAP_CL_REQ_CUR > $STAT_FILE_CL


       fi

             PRSTAT_OUT=`prstat -p $WPPID 1 1 | grep "wapproxyd" | awk '{ print $1" "$9" "$3" "$4" "$5" "$10}'`
             PROXY_START=`echo "${WP_OUTPUT}" | grep "Proxy server start-up time" | cut -d " " -f 9,10`
       ACTIVE_PROXY_CONN=`echo "${WP_OUTPUT}" | grep "Active proxy" | cut -d "=" -f 2`
       ACTIVE_PROXY_CONN=${ACTIVE_PROXY_CONN//" "/""}
       WEB_REQUESTS_COUNT=`echo "${WP_OUTPUT}" | grep "Pending proxy server web-requests" | cut -d "=" -f 2`
       WEB_REQUESTS_COUNT=${WEB_REQUESTS_COUNT//" "/""}

            # some actions here ...
       RESULT_LINE="${RESULT_LINE} ${PRSTAT_OUT} ${PROXY_START} ${ACTIVE_PROXY_CONN} ${WEB_REQUESTS_COUNT} ${REAL_TPS}"


            echo $RESULT_LINE >> ${FILENAME}
            exit 0
        fi
    fi
done

 FILENAME=$WAPINSTBASE/wpstat/wpstopstat_${SRVID}_${PROXYID}_`date '+%Y%m%d'`.log

echo $RESULT_LINE >> ${FILENAME}
exit 1
