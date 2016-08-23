#!/bin/bash

sudo /usr/sbin/sshd



start_scdf_admin () {
  cd /data/
  java -jar spring-cloud-dataflow-server-local-*.BUILD-SNAPSHOT.jar &
}

start_scdf_shell () {
  cd /data/
  java -jar spring-cloud-dataflow-shell-*.BUILD-SNAPSHOT.jar &
}


if [ "${HOSTNAME}" == "centos7-scdf-datanode1" ]; then
  echo "Will start scdf admin and shell on this node"
  start_scdf_admin
  start_scdf_shell
else
  echo "No scdf needed on this node"
fi
