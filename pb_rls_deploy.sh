#!/bin/bash

Z_BASE_DIR=$(cd `dirname $0` && pwd)

function ex {
  while [ $# -gt 0 ]; do
    echo `printf '!!!   %s   !!!' "$1"`
    shift
  done
  exit 1
}

fcdb_home=$2
if [ "$fcdb_home" == "" ] || [ ! -d "$fcdb_home/deploy" ]; then
  read -e -p "Enter FCDB home path: " fcdb_home
  if [ ! -d "$fcdb_home/deploy" ]; then
    ex 'Wrong FCDB home'
  fi
fi

release_number=$1
if [ "$release_number" == "" ] || [ ! -f "$Z_BASE_DIR/release-$release_number.zip" ]; then
  read -p 'Enter release number: ' release_number
  if [ ! -f "$Z_BASE_DIR/release-$release_number.zip" ]; then
    ex 'Wrong release number'
  fi
fi
release_name=release-$release_number
release_dir=$Z_BASE_DIR/$release_name
if [ -d $release_dir ]; then
  rm -fR $release_dir
fi

unzip -q $release_dir.zip -d $release_dir
if [ ! -d $release_dir ]; then
  ex "Failed to extract release $release_number"
fi
echo "Release $release_number extracted successfully"

cp $release_dir/*.war $fcdb_home/deploy/
cp $release_dir/fcdb-home/system/home/*001.xml $fcdb_home/system/home/
cp $release_dir/fcdb-home/system/home/fcat-config.xml $fcdb_home/system/home/
cp $release_dir/fcdb-home/system/home/fcat.properties $fcdb_home/system/home/
cp $release_dir/fcdb-home/system/home/logger.properties $fcdb_home/system/home/
cp $release_dir/fcdb-home/system/home/appldata.xml $fcdb_home/system/home/
cp $release_dir/fcdb-home/system/home/jfformatter.xml $fcdb_home/system/home/
cp -r $release_dir/fcdb-home/custom/* $fcdb_home/custom
cp $release_dir/fcdb-home/system/datafiles/gui.zip $fcdb_home/system/datafiles/gui/
cp $release_dir/fcdb-home/system/datafiles/hostinterface.zip $fcdb_home/system/datafiles/hostinterface/
cp $release_dir/fcdb-home/system/datafiles/services.zip $fcdb_home/system/datafiles/services/
unzip -q -o $fcdb_home/system/datafiles/gui/gui.zip -d $fcdb_home/system/datafiles/gui/
unzip -q -o $fcdb_home/system/datafiles/hostinterface/hostinterface.zip -d $fcdb_home/system/datafiles/hostinterface/
unzip -q -o $fcdb_home/system/datafiles/services/services.zip -d $fcdb_home/system/datafiles/services/
