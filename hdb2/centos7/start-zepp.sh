#!/bin/bash

sudo /usr/sbin/sshd

donwload_zeppelin () {
  curl -O http://apache.cs.utah.edu/zeppelin/zeppelin-0.6.1/zeppelin-0.6.1-bin-all.tgz
}

unzip_zeppelin () {
  tar -xvzf /tmp/zeppelin-0.6.1-bin-netinst.tgz -C /usr/local/
}

start_zeppelin () {
  /usr/local/zeppelin/bin/zeppelin-daemon.sh start &
}

if [ "${HOSTNAME}" == "centos7-zepp-datanode1" ]; then
  echo "Will install zeppelin on this node"
  unzip_zeppelin
  start_zeppelin
else
  echo "No zeppelin needed"
fi
