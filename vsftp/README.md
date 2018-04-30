>sudo apt-get install vsftpd

>mkdir /srv/ftp

>sudo vi /etc/shells

>add new line "/usr/bin/ftp"

>sudo useradd -d /srv/ftp -s /usr/bin/ftp ftpuser

>sudo passwd ftpuser
