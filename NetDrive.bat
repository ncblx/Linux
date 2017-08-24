@Echo
if exist L: GOTO STEP1
if not exist L: net use \\10.10.1.50\VasBackup /d /yes | net use L: /d /yes | net use L: \\10.10.1.50\VasBackup /User:azerfon\vasuser 123456789F!



:STEP1
echo exit
