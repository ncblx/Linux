#!/bin/bash

STATUS=$(VBoxManage list runningvms |grep -i docker | wc -l)

echo "Check status of VBox" 
if [ $STATUS -eq  1 ]; 
then 
	echo "Started"
else	
	VBoxManage startvm Docker --type headless
	sleep 15
	VBoxManage controlvm Docker setlinkstate1 off
	sleep 5
	VBoxManage controlvm Docker setlinkstate1 on
	echo "VBox Docker has been started"
fi
#VBoxManage list vms --long | grep -e "Name:" -e "State:"