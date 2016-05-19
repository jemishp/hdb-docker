#!/bin/bash

/usr/sbin/sshd

if [ -f /etc/profile.d/hadoop.sh ]; then
  . /etc/profile.d/hadoop.sh
fi

if [ "${NAMENODE}" == "${HOSTNAME}" ]; then
  if [ ! -d /tmp/hdfs/name/current ]; then
    su -l hdfs -c "hdfs namenode -format"
  fi
  
  if [ -z "`ps aux | grep org.apache.hadoop.hdfs.server.namenode.NameNode | grep -v grep`" ]; then
    su -l hdfs -c "hadoop-daemon.sh start namenode"
    sudo -u hdfs hdfs dfs -chmod 777 /
    sudo -u hdfs hdfs dfs -mkdir /hawq_default
    sudo -u hdfs hdfs dfs -chown gpadmin:gpadmin /hawq_default
  fi
else
  if [ -z "`ps aux | grep org.apache.hadoop.hdfs.server.datanode.DataNode | grep -v grep`" ]; then
    su -l hdfs -c "hadoop-daemon.sh start datanode"
  fi
fi

su -l gpadmin -c "start-hdb.sh"

