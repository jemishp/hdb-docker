#!/bin/bash

sudo /usr/sbin/sshd

if [ -f /etc/profile.d/hadoop.sh ]; then
  . /etc/profile.d/hadoop.sh
fi


if [ "${NAMENODE}" == "${HOSTNAME}" ]; then
 echo 'starting PXF on master' > /home/gpadmin/start_hdb.log
 sudo service pxf-service start
 if [ "`sudo -u hdfs hdfs dfsadmin -report | grep Live | awk '{print $3}' | tr -d "(|)" | tr -d ":"`" == 3 ]; then
   #  start Hawq as we are on Master
   echo "hdfs is alive and starting HAWQ on ${HOSTNAME} " >> /home/gpadmin/start_hdb.log
   echo "running as user `whoami` " >> /home/gpadmin/start_hdb.log
   if [ ! -d /home/gpadmin/hawq-data-directory/masterdd ]; then
     sed 's|localhost|centos7-namenode|g' -i /data/hdb2/etc/hawq-site.xml
     echo 'centos7-datanode1' > /data/hdb2/etc/slaves
     echo 'centos7-datanode2' >> /data/hdb2/etc/slaves
     echo 'centos7-datanode3' >> /data/hdb2/etc/slaves
     echo "edited the slaves file " >> /home/gpadmin/start_hdb.log
     source /data/hdb2/greenplum_path.sh
     hawq init cluster -a
     echo "cluster inited" >> /home/gpadmin/start_hdb.log
     createdb
     echo "DB created" >> /home/gpadmin/start_hdb.log
     echo "host  all     gpadmin    0.0.0.0/0       trust" >> /home/gpadmin/hawq-data-directory/masterdd/pg_hba.conf
     echo "allowed gpadmin access from any host without password" >> /home/gpadmin/start_hdb.log
     hawq config -c optimizer_analyze_root_partition -v on
     hawq config -c optimizer -v on
     echo "enabled root partition stats and turned optimizer on" >> /home/gpadmin/start_hdb.log
     gppkg install /data/madlib-ossv1.9_pv1.9.5_hawq2.0-rhel5-x86_64.tar.gz
     /usr/local/madlib/bin/madpack –p hawq install
     echo "Installed MADlib" >> /home/gpadmin/start_hdb.log
     hawq restart cluster -a
     echo "HDB config reloaded" >> /home/gpadmin/start_hdb.log
     echo "HDB should be up" >> /home/gpadmin/start_hdb.log
     echo "`ps aux | grep postgres | grep -v grep`" >> /home/gpadmin/start_hdb.log
   else
 
   if [ -d /home/gpadmin/hawq-data-directory/masterdd ]; then
     echo "masterdd exists" >> /home/gpadmin/start_hdb.log
     if [ -z "`ps aux | grep masterdd | grep -v grep `" ]; then
       echo "HDB already running " >> /home/gpadmin/start_hdb.log
       echo "`ps aux | grep postgres | grep -v grep`" >> /home/gpadmin/start_hdb.log
     else
       echo "starting HDB processes" >> /home/gpadmin/start_hdb.log
       source /data/hdb2/greenplum_path.sh
       hawq start cluster -a
       echo "HDB should be up" >> /home/gpadmin/start_hdb.log
       echo "`ps aux | grep postgres | grep -v grep`" >> /home/gpadmin/start_hdb.log
     fi
    fi
   fi
 else
  echo "Need to start HDFS"
 fi
else
  echo 'starting PXF on segments' >> /home/gpadmin/start_hdb.log
  sudo service pxf-service start
fi
