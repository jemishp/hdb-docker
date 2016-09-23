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
  if [ -f demo.cmd ]; then
    rm -f demo.cmd
  fi
  echo -e 'dataflow config server http://localhost:9393/' >> demo.cmd
  echo -e 'app import --uri http://bit.ly/stream-applications-kafka-maven' >> demo.cmd
  echo -e 'stream all destroy --force ' >> demo.cmd
  echo -e 'stream create --name demo --definition "http --server.port=9000 | hdfs --hdfs.fs-uri=hdfs://centos7-namenode --hdfs.directory=/demo --hdfs.file-name=demoData --hdfs.rollover=100000" --deploy' >> demo.cmd
  echo 'script --file demo.cmd' | java -jar spring-cloud-dataflow-shell-*.BUILD-SNAPSHOT.jar



}


if [ "${HOSTNAME}" == "centos7-scdf-datanode1" ]; then
  echo "Will start scdf admin and shell on this node"
  start_scdf_admin
  start_scdf_shell
else
  echo "No scdf needed on this node"
fi
