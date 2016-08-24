#!/bin/bash

sudo /usr/sbin/sshd



start_scdf_admin () {
  cd /data/
  java -jar spring-cloud-dataflow-server-local-1.0.1.BUILD-SNAPSHOT.jar \
  --spring.cloud.dataflow.applicationProperties.stream.spring.cloud.stream.kafka.binder.brokers=centos7-kafka:9092 \
  --spring.cloud.dataflow.applicationProperties.stream.spring.cloud.stream.kafka.binder.zkNodes=centos7-kafka:2181 > ~/scdf-admin.log &
}

start_scdf_shell () {
  cd /data/
  java -jar spring-cloud-dataflow-shell-*.BUILD-SNAPSHOT.jar & \
  app import --uri http://bit.ly/stream-applications-kafka-maven
  
}


if [ "${HOSTNAME}" == "centos7-scdf-datanode1" ]; then
  echo "Will start scdf admin and shell on this node"
  start_scdf_admin
  #start_scdf_shell
else
  echo "No scdf needed on this node"
fi
