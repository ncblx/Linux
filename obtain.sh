#!/bin/bash

FILENAME="wpstat_wapgw"

FILE_EXT="1_20090403.log"

COUNT_OF_DAYS=1

COUNT_OF_FILES=`ls ./${FILENAME}*${FILE_EXT} | wc -l`

echo "Count files for parsing = ${COUNT_OF_FILES}"

I=0

while [ ${I} -lt ${COUNT_OF_FILES} ]
do
  I=$[I+1]
  proc_file=`ls -l ./${FILENAME}*${FILE_EXT} | awk '{print $9}' | head --lines ${I} | tail --lines 1`

echo Processing file: $proc_file
  awk '
  {
    print  $1" "$2" "$11" "$12" "$13
  }' ${proc_file} >> ./test.csv

done

sort -k 1,2 -o ./test.csv ./test.csv


awk -v num=${COUNT_OF_FILES} -v sum_conn=0 -v sum_trs=0 -v sum_TPS=0 -v count=0 -v days=${COUNT_OF_DAYS} '
{
    num_per_day=num/days;
    sum_conn += $3;
    sum_trs += $4;
    sum_TPS += $5;

    count = count + 1;

    if (count == num_per_day)
    {

      yy=substr($1,1,4);
      mm=substr($1,6,2);
      dd=substr($1,9,2);
      time=substr($2,1,8);
      print "\""mm"/"dd"/"yy" "time".000\",\"" sum_conn "\",\"" sum_trs "\",\"" sum_TPS "\"";
      count=0;
      sum_conn=0;
      sum_trs=0;
      sum_TPS=0;
    }


}' ./test.csv > ./out

cat ./out  | head --lines 1440 | sort -t "\"" -n -k 7 | tail --lines 1 > ./out_tr_max
J=1
while [ ${J} -lt ${COUNT_OF_DAYS} ]
do
  J=$[J+1]
  lines_begin=`expr 1440 \* $J`
  cat ./out  | head --lines ${lines_begin} | tail --lines 1440 | sort -t "\"" -n -k 7 | tail --lines 1 >> ./out_tr_max

done
echo "\"(PDH-CSV 4.0) (Russian Standard Time)(-180)\",\"\\\\z100000\\WAP GW\\Connection\",\"\\\\z100000\\WAP GW\\Pending web-requests\",\"\\\\z100000\\WAP GW\\TPS\"" > ./graph.csv
echo "\"(PDH-CSV 4.0) (Russian Standard Time)(-180)\",\"\\\\z100000\\WAP GW\\Connection\",\"\\\\z100000\\WAP GW\\Pending web-requests\",\"\\\\z100000\\WAP GW\\TPS\"" > ./graph_lic.csv
cat ./out >> ./graph.csv
cat ./out_tr_max >> ./graph_lic.csv
#rm ./out
#rm ./test.csv
#rm ./out_tr_max
