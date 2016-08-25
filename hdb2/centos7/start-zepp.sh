#!/bin/bash

sudo /usr/sbin/sshd

download_zeppelin () {
  cd /tmp/
  curl -O http://apache.mirrors.pair.com/zeppelin/zeppelin-0.6.1/zeppelin-0.6.1-bin-netinst.tgz
}

unzip_zeppelin () {
  sudo tar -xvzf /tmp/zeppelin-0.6.1-bin-netinst.tgz -C /usr/local/
}

start_zeppelin () {
  sudo /usr/local/zeppelin-*/bin/zeppelin-daemon.sh start
}

install_interpreters () {
  sudo /usr/local/zeppelin-*/bin/install-interpreter.sh -n shell,python,postgresql,file,angular,md,jdbc,elasticsearch,hbase
  sudo /usr/local/zeppelin-*/bin/zeppelin-daemon.sh restart 
}

if [ "${HOSTNAME}" == "centos7-zepp-datanode1" ]; then
  echo "Will install zeppelin on this node"
  download_zeppelin
  unzip_zeppelin
  start_zeppelin
  install_interpreters
else
  echo "No zeppelin needed"
fi
