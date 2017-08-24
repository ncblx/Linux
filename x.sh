zgrep "3GPP-RAT-Type = 6" auth_log-201602* > 1
zgrep "3GPP-RAT-Type = 6" auth_log-201601* >> 1
grep Access-Accept 1 > 11
#zgrep "3GPP-RAT-Type = 6" auth_log-2015113* >> 1

#grep "3GPP-RAT-Type = 6" auth_log-20151127_10.log* >> 1
cat /var/log/radius/11 | awk '{print $8}' > /var/log/radius/listall
sort /var/log/radius/listall | uniq > /var/log/radius/listalluniq0224
cat /var/log/radius/11 | awk '{print $2" " $8}' > /var/log/radius/list
sort  /var/log/radius/list |uniq > /var/log/radius/listbydateuniq
cat /var/log/radius/list |cut -d' ' -f1 |uniq -c > /var/log/radius/listbydatetotal0224
cat /var/log/radius/listbydateuniq |cut -d' ' -f1 |uniq -c > /var/log/radius/listbydateuniq02242016

