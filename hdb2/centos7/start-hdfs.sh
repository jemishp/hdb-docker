#!/bin/bash

/usr/sbin/sshd

if [ -f /etc/profile.d/hadoop.sh ]; then
  . /etc/profile.d/hadoop.sh
fi

if [ "${NAMENODE}" == "${HOSTNAME}" ]; then
  if [ ! -d /tmp/hdfs/name/current ]; then
    sudo sed -i "s/\${hdfs.namenode}/${NAMENODE}/g" /etc/hadoop/conf/core-site.xml
    sudo sed -i "s/\${user.name}/${USER}/g" /etc/hadoop/conf/hdfs-site.xml
    su -l hdfs -c "hdfs namenode -format"
  fi

  if [ -z "`ps aux | grep org.apache.hadoop.hdfs.server.namenode.NameNode | grep -v grep`" ]; then
    sudo sed -i "s/\${hdfs.namenode}/${NAMENODE}/g" /etc/hadoop/conf/core-site.xml
    sudo sed -i "s/\${user.name}/${USER}/g" /etc/hadoop/conf/hdfs-site.xml
    su -l hdfs -c "hadoop-daemon.sh start namenode"
    sudo -u hdfs hdfs dfs -chmod 777 /
  fi
else
  if [ -z "`ps aux | grep org.apache.hadoop.hdfs.server.datanode.DataNode | grep -v grep`" ]; then
    sudo sed -i "s/\${hdfs.namenode}/${NAMENODE}/g" /etc/hadoop/conf/core-site.xml
    sudo sed -i "s/\${user.name}/${USER}/g" /etc/hadoop/conf/hdfs-site.xml
    su -l hdfs -c "hadoop-daemon.sh start datanode"
  fi
fi

su -l gpadmin -c "start-hdb.sh"
su -l gpadmin -c "start-scdf.sh"
su -l gpadmin -c "start-zepp.sh"
