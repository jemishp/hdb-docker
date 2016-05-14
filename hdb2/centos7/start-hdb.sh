#!/bin/bash

sudo /usr/sbin/sshd

if [ -f /etc/profile.d/hadoop.sh ]; then
  . /etc/profile.d/hadoop.sh
fi


if [ "${NAMENODE}" == "${HOSTNAME}" ]; then
 echo 'sleeping ' > /home/gpadmin/start_hdb.log
 sleep 20
 if [ "`sudo -u hdfs hdfs dfsadmin -report | grep Live | awk '{print $3}' | tr -d "(|)" | tr -d ":"`" == 3 ]; then
   #  start Hawq as we are on Master
   echo "hdfs is alive and starting HAWQ on ${HOSTNAME} " >> /home/gpadmin/start_hdb.log
   if [ ! -d /home/gpadmin/hawq-data-directory/masterdd ]; then
     sed 's|localhost|centos7-namenode|g' -i /data/hdb2/etc/hawq-site.xml
     echo 'centos7-datanode1' > /data/hdb2/etc/slaves
     echo 'centos7-datanode2' >> /data/hdb2/etc/slaves
     echo 'centos7-datanode3' >> /data/hdb2/etc/slaves
     source /data/hdb2/greenplum_path.sh
     hawq init cluster -a
     createdb
   fi
 
   if [ -d /home/gpadmin/hawq-data-directory/masterdd ]; then
     echo "masterdd exists" >> /home/gpadmin/start_hdb.log
     if [ -z "`ps aux | grep masterdd | grep -v grep `" ]; then
       echo "HDB already running " >> /home/gpadmin/start_hdb.log
     else
       echo "starting HDB processes" >> /home/gpadmin/start_hdb.log
       source /data/hdb2/greenplum_path.sh
       hawq start cluster -a
     fi
   fi
 else
  echo "Need to start HDFS"
 fi
else
  echo "do nothing on Segments"
fi
