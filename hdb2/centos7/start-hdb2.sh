#!/bin/bash

sudo /usr/sbin/sshd


config_pxf () {
  sudo sed -i 's|/usr/lib/hadoop/lib/native|/usr/hdp/current/hadoop-client/lib/native|' /etc/pxf/conf/pxf-env.sh
  sudo sed -i 's|/usr/java/default|/etc/alternatives/java_sdk|' /etc/pxf/conf/pxf-env.sh
  sudo sed -i '$ a\# Hadoop HOME directory'  /etc/pxf/conf/pxf-env.sh
  sudo sed -i 'export HADOOP_HOME=/usr/hdp/current/hadoop-client' /etc/pxf/conf/pxf-env.sh
}

init_pxf () {
  sudo service pxf-service init
}

start_pxf () {
    sudo service pxf-service start
}

config_hdfs_perms () {
  sudo -u hdfs hdfs dfs -chmod 777 /
}

config_slaves () {
  sed 's|localhost|centos7-namenode|g' -i /data/hdb2/etc/hawq-site.xml
  echo 'centos7-datanode1' > /data/hdb2/etc/slaves
  echo 'centos7-datanode2' >> /data/hdb2/etc/slaves
  echo 'centos7-datanode3' >> /data/hdb2/etc/slaves
  echo "edited the slaves file " >> /home/gpadmin/start_hdb.log
}

config_access () {
  echo "host  all     gpadmin    0.0.0.0/0       trust" >> /home/gpadmin/hawq-data-directory/masterdd/pg_hba.conf
}

config_guc () {
  source /data/hdb2/greenplum_path.sh
  hawq config -c optimizer_analyze_root_partition -v on
  hawq config -c optimizer -v on
}

init_hawq () {
  source /data/hdb2/greenplum_path.sh
  hawq init cluster -a
}

inst_madlib () {
  source /data/hdb2/greenplum_path.sh
  cd /tmp
  tar -xzf madlib-ossv1.9_pv1.9.5_hawq2.0-rhel5-x86_64.tar.gz
  gppkg -i /tmp/madlib-ossv1.9_pv1.9.5_hawq2.0-rhel5-x86_64.gppkg -d /home/gpadmin/hawq-data-directory/masterdd
  /data/hdb2/madlib/bin/madpack -p hawq install
}

start_hawq () {
  source /data/hdb2/greenplum_path.sh
  hawq start cluster -a
}

restart_hawq () {
   source /data/hdb2/greenplum_path.sh
   hawq restart cluster -a
}



if [ -f /etc/profile.d/hadoop.sh ]; then
  . /etc/profile.d/hadoop.sh
fi
if [ -f /etc/profile.d/java.sh ]; then
  . /etc/profile.d/java.sh
fi

if [ "${NAMENODE}" == "${HOSTNAME}" ]; then
 sleep 5
 echo 'init and start PXF on master' > /home/gpadmin/start_hdb.log
 config_pxf
 init_pxf
 start_pxf
 if [ "`sudo -u hdfs hdfs dfsadmin -report | grep Live | awk '{print $3}' | tr -d "(|)" | tr -d ":"`" == 3 ]; then
   #  start Hawq as we are on Master
   echo "hdfs is alive and starting HAWQ on ${HOSTNAME} " >> /home/gpadmin/start_hdb.log
   echo "running as user `whoami` " >> /home/gpadmin/start_hdb.log
   config_hdfs_perms
   if [ ! -d /home/gpadmin/hawq-data-directory/masterdd ]; then
     config_slaves
     init_hawq
     echo "cluster inited" >> /home/gpadmin/start_hdb.log
     createdb
     echo "DB created" >> /home/gpadmin/start_hdb.log
     config_access
     echo "allowed gpadmin access from any host without password" >> /home/gpadmin/start_hdb.log
     #config_guc
     #echo "enabled root partition stats and turned optimizer on" >> /home/gpadmin/start_hdb.log
     inst_madlib
     echo "Installed MADlib" >> /home/gpadmin/start_hdb.log
     restart_hawq
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
       start_hawq
       echo "HDB should be up" >> /home/gpadmin/start_hdb.log
       echo "`ps aux | grep postgres | grep -v grep`" >> /home/gpadmin/start_hdb.log
     fi
    fi
   fi
 else
  echo "Need to start HDFS" >> /home/gpadmin/start_hdb.log
 fi
else
  echo "starting PXF on segments" >> /home/gpadmin/start_hdb.log
  config_pxf
  init_pxf
  start_pxf
fi
