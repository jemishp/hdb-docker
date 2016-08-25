#!/bin/bash

sudo /usr/sbin/sshd


config_pxf () {
  sudo sed -i 's|/usr/lib/hadoop/lib/native|/usr/hdp/current/hadoop-client/lib/native|' /etc/pxf/conf/pxf-env.sh
  sudo sed -i 's|/usr/java/default|/etc/alternatives/java_sdk|' /etc/pxf/conf/pxf-env.sh
  sudo sed -i '$ a\# Hadoop HOME directory'  /etc/pxf/conf/pxf-env.sh
  sudo sed -i '$ a\ export HADOOP_HOME=/usr/hdp/current/hadoop-client' /etc/pxf/conf/pxf-env.sh
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

config_workers () {
  sed 's|localhost|centos7-namenode|g' -i /data/hdb2/etc/hawq-site.xml
  echo 'centos7-datanode1' > /data/hdb2/etc/slaves
  echo 'centos7-datanode2' >> /data/hdb2/etc/slaves
  echo 'centos7-datanode3' >> /data/hdb2/etc/slaves
  echo "edited the slaves file " >> /home/gpadmin/start_hdb.log
}

config_bashrc () {
  echo "source /data/hdb2/greenplum_path.sh" >> /home/gpadmin/.bashrc
  source ~/.bashrc
}
config_access () {
  echo "host  all     gpadmin    0.0.0.0/0       trust" >> /home/gpadmin/hawq-data-directory/masterdd/pg_hba.conf
}

config_guc () {
  hawq config -c optimizer_analyze_root_partition -v on
  hawq config -c optimizer -v on
  hawq config -c default_hash_table_bucket_number -v 6
}

init_hawq () {
  sudo ldconfig
  hawq init cluster -a
}

inst_madlib () {
  cd /tmp
  sudo rpm -i /tmp/madlib-1.9-1.x86_64.rpm
  if [ "${NAMENODE}" == "${HOSTNAME}" ]; then
    /usr/local/madlib/bin/madpack -p hawq install
  fi
}

start_hawq () {
  hawq start cluster -a
}

restart_hawq () {
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
 if [ "`sudo -u hdfs hdfs dfsadmin -report | grep Live | awk '{print $3}' | tr -d "(|)" | tr -d ":"`" -ge 3 ]; then
   #  start Hawq as we are on Master
   echo "hdfs is alive and starting HAWQ on ${HOSTNAME} " >> /home/gpadmin/start_hdb.log
   echo "running as user `whoami` " >> /home/gpadmin/start_hdb.log
   config_hdfs_perms
   if [ ! -d /home/gpadmin/hawq-data-directory/masterdd ]; then
     config_bashrc
     config_workers
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
  config_bashrc
  inst_madlib
fi
