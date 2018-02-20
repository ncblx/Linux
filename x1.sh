#!/bin/bash
a=`date '+%m' --date '1 month ago'`
zgrep "Status = Access-Accept" /var/log/radius/auth_log-2016$a* > /var/log/radius/w

grep "3GPP-RAT-Type = 6" /var/log/radius/w > /var/log/radius/1
cat /var/log/radius/1.82 >> /var/log/radius/1
rm /var/log/radius/w
rm  /var/log/radius/1.82
#zgrep "3GPP-RAT-Type = 6" auth_log-201605* >> 1
#zgrep "3GPP-RAT-Type = 6" auth_log-2015113* >> 1

#grep "3GPP-RAT-Type = 6" auth_log-20151127_10.log* >> 1
cat /var/log/radius/1 | awk '{print $8}' > /var/log/radius/listall
rm  /var/log/radius/1
sort /var/log/radius/listall | uniq > /var/log/radius/listalluniq1003
#cat /var/log/radius/1 | awk '{print $2" " $8}' > /var/log/radius/list
#sort  /var/log/radius/list |uniq > /var/log/radius/listbydateuniq
#cat /var/log/radius/list |cut -d' ' -f1 |uniq -c > /var/log/radius/listbydatetota1307
#cat /var/log/radius/listbydateuniq |cut -d' ' -f1 |uniq -c > /var/log/radius/listbydateuniq1307

#cat /var/log/radius/listalluniq1307 >> /var/log/radius/listall13072016
#sort /var/log/radius/listall13072016 | uniq > /var/log/radius/listall130720162

cut -d ',' -f1 /var/log/radius/listalluniq1003 > /var/log/radius/listalluniq10031 
#cut -d ',' -f1 /var/log/radius/listall130720162 > /var/log/radius/listalluniq130720161
awk -v date="$(date +"%m-%Y" --date '1 month ago')" '{print date","$0}' /var/log/radius/listalluniq10031 > listalluniq1003.txt


#awk '{print "09-2016," $0}' /var/log/radius/listalluniq10031 > listalluniq1003.txt
#sed -e "s/$/ $a-2016/" -i /var/log/radius/listalluniq13071 
#sed -e "s/$/07-2016/" -i /var/log/radius/listall130720161

#awk '{print $2","$1}' /var/log/radius/listalluniq13071 > listalluniq1307.txt
#awk '{print $2","$1}' /var/log/radius/listall130720161 > listall13072016.txt
#date '+%m' --date '1 month ago'
