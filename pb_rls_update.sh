#!/bin/bash

Z_BASE_DIR=$(cd `dirname $0` && pwd)

function ex {
  while [ $# -gt 0 ]; do
    echo `printf '!!!   %s   !!!' "$1"`
    shift
  done
  exit 1
}

release_number=$1
if [ "$release_number" == "" ] || [ ! -d "$Z_BASE_DIR/release-$release_number" ]; then
  read -p 'Enter release number: ' release_number
  if [ ! -d "$Z_BASE_DIR/release-$release_number" ]; then
    ex 'Wrong release number'
  fi
fi
release_name=release-$release_number

Z_BASE_DIR=$(cd `dirname $0` && pwd)

function ex {
  while [ $# -gt 0 ]; do
    echo `printf '!!!   %s   !!!' "$1"`
    shift
  done
  exit 1
}

release_number=$1
if [ "$release_number" == "" ] || [ ! -d "$Z_BASE_DIR/release-$release_number" ]; then
  read -p 'Enter release number: ' release_number
  if [ ! -d "$Z_BASE_DIR/release-$release_number" ]; then
    ex 'Wrong release number'
  fi
fi
release_name=release-$release_number
release_dir=$Z_BASE_DIR/$release_name

sql_current=$2
if [ "$sql_current" == "" ]; then
  read -p 'Enter current SQL level: ' sql_current
fi

sql_target=$3
if [ "$sql_target" == "" ]; then
  read -p 'Enter target SQL level:  ' sql_target
fi

sql_log=update_${release_number}_${sql_current}_${sql_target}_`date +%Y%m%d_%H%M`.log
sql_sources=()
for sql_dir in `ls -v $release_dir/sql | awk 'BEGIN{start=0} /^'"$sql_current"'$/{start=1} {if(start==1){print $0}} /^'"$sql_target"'$/{start=0}'`; do
  sql_sources=(${sql_sources[*]} $sql_dir)
done
echo -n 'SQL sources found: '
echo ${sql_sources[*]}
read -p 'Is it correct [y/n]? ' answer
if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
  exit
fi

read -p 'DB Admin user:       ' db_admin_user
read -p 'DB App user:         ' db_app_user
read -p 'DB App role:         ' db_app_role
read -s -p 'DB password:       ' db_password && echo
read -p 'DB connect string: ' db_connect

cd $release_dir/sql
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
export NLS_LANG=American_America.UTF8
for sql_dir in ${sql_sources[*]}; do
  if [ -f "$sql_dir/fcdbadmin.sql" ]; then
    $ORACLE_HOME/bin/sqlplus -L /nolog <<EOF
connect $db_admin_user/$db_password@"$db_connect"
define fcdbappprole=$db_app_role
define fcdbb001user=$db_app_user
define fcdbadminuser=$db_admin_user
define fcatfcclink=FCATFCCLINK
set sqlblanklines on
spool ../$sql_log append
@$sql_dir/fcdbadmin.sql $sql_dir
commit;                                                                                                                                                                                                                   
spool off                                                                                                                                                                                                                 
EOF                                                                                                                                                                                                                       
  fi                                                                                                                                                                                                                      
  if [ -f "$sql_dir/fcdbb001.sql" ]; then                                                                                                                                                                                 
    $ORACLE_HOME/bin/sqlplus -L /nolog <<EOF                                                                                                                                                                              
connect $db_app_user/$db_password@"$db_connect"                                                                                                                                                                           
define fcdbappprole=$db_app_role                                                                                                                                                                                          
define fcdbb001user=$db_app_user                                                                                                                                                                                          
define fcdbadminuser=$db_admin_user                                                                                                                                                                                       
define fcatfcclink=FCATFCCLINK                                                                                                                                                                                            
set sqlblanklines on                                                                                                                                                                                                      
spool ../$sql_log append                                                                                                                                                                                                  
@$sql_dir/fcdbb001.sql $sql_dir                                                                                                                                                                                           
commit;                                                                                                                                                                                                                   
spool off                                                                                                                                                                                                                 
EOF                                                                                                                                                                                                                       
  fi                                                                                                                                                                                                                      
done                    
