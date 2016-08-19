#!/usr/bin/make all

THIS_MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
TOP_DIR := $(abspath $(dir ${THIS_MAKEFILE_PATH}))
NDATANODES := 3
CUR_DATANODE := 1
OS_VERSION := centos7
# Do not use underscore "_" in CLUSTER_ID
CLUSTER_ID := $(OS_VERSION)
# Monut this local directory to /data in data container and share with other containers
LOCAL :=
# networks used in docker
NETWORK := $(CLUSTER_ID)_hawq_network
ZEPP := 1
SCDF := 1

all:
	@echo " Usage:"
	@echo "    To setup a build and test environment:         make run"
	@echo "    To start all containers:                       make start"
	@echo "    To stop all containers:                        make stop"
	@echo "    To remove hdfs containers:                     make clean"
	@echo "    To remove all containers:                      make distclean"
	@echo ""
	@echo "    To build images locally:                       make build"
	@echo "    To pull latest images:                         make pull"

build:
	@make -f $(THIS_MAKEFILE_PATH) build-hawq-devel-$(OS_VERSION)
	@echo "Done!"

build-hawq-devel-$(OS_VERSION): $(TOP_DIR)/$(OS_VERSION)/Dockerfile
	@echo build jpatel4pivotal/hdb2:$(OS_VERSION) image
	docker build -t jpatel4pivotal/hdb2:$(OS_VERSION) $(TOP_DIR)/$(OS_VERSION)/


create-data-container:
	@echo create ${CLUSTER_ID}-data container
	@if [ ! -z "$(LOCAL)" -a ! -d "$(LOCAL)" ]; then \
		echo "LOCAL must be set to a directory!"; \
		exit 1; \
	fi
	@if [ -z "`docker ps -a --filter="name=${CLUSTER_ID}-data$$" | grep -v CONTAINER`" ]; then \
		if [ -z "$(LOCAL)" ]; then \
			docker create -v /data --name=${CLUSTER_ID}-data jpatel4pivotal/hdb2:$(OS_VERSION) /bin/true; \
		else \
			docker create -v $(LOCAL):/data --name=${CLUSTER_ID}-data jpatel4pivotal/hdb2:$(OS_VERSION) /bin/true; \
		fi \
	else \
		echo "${CLUSTER_ID}-data container already exist!"; \
	fi

run:
	@if [ -z "`docker network ls 2>/dev/null`" ]; then \
                make -f $(THIS_MAKEFILE_PATH) NETWORK=default create-data-container && \
                make -f $(THIS_MAKEFILE_PATH) NETWORK=default run-hdfs; \
	else \
	        if [ -z "`docker network ls 2>/dev/null | grep $(NETWORK)`" ]; then \
	                echo create network $(NETWORK) && \
	                docker network create --driver bridge $(NETWORK); \
	        fi && \
	        make -f $(THIS_MAKEFILE_PATH) create-data-container && \
                make -f $(THIS_MAKEFILE_PATH) run-hdfs  && \
              	if [ ${ZEPP} = 1 ]; then make -f $(THIS_MAKEFILE_PATH) run-zepp-container ; fi && \
              	if [ ${SCDF} = 1 ]; then make -f $(THIS_MAKEFILE_PATH) run-scdf-container ; fi \
	fi

run-hdfs:
	@make -f $(THIS_MAKEFILE_PATH) run-namenode-container
	@i=1; \
	while [ $$i -le $(NDATANODES) ] ; do \
		make -f $(THIS_MAKEFILE_PATH) CUR_DATANODE=$$i run-datanode-container; \
		i=$$((i+1)); \
	done
	@echo "Done!"
	@echo 'run "docker exec -it ${CLUSTER_ID}-namenode bash" to attach to ${CLUSTER_ID}-namenode node'

run-namenode-container:
	@echo "run ${CLUSTER_ID}-namenode container"
	@if [ -z "`docker ps -a --filter="name=${CLUSTER_ID}-namenode" | grep -v CONTAINER`" ]; then \
		docker run -itd  -p 5432:5432 -p 4444:22 --privileged --net=$(NETWORK) --hostname=${CLUSTER_ID}-namenode --name=${CLUSTER_ID}-namenode \
			--volumes-from ${CLUSTER_ID}-data jpatel4pivotal/hdb2:$(OS_VERSION); \
	else \
		echo "${CLUSTER_ID}-namenode container already exist!"; \
	fi

run-datanode-container:
	@echo "run ${CLUSTER_ID}-datanode$(CUR_DATANODE) container"
	@if [ -z "`docker ps -a --filter="name=${CLUSTER_ID}-datanode$(CUR_DATANODE)" | grep -v CONTAINER`" ]; then \
		docker run -itd --net=$(NETWORK) --hostname=${CLUSTER_ID}-datanode$(CUR_DATANODE) \
			--name=${CLUSTER_ID}-datanode$(CUR_DATANODE) -e NAMENODE=${CLUSTER_ID}-namenode \
		  --volumes-from ${CLUSTER_ID}-data jpatel4pivotal/hdb2:$(OS_VERSION); \
	else \
		echo "${CLUSTER_ID}-datanode$(CUR_DATANODE) container already exist!"; \
	fi

run-zepp-container:
	@echo "run ${CLUSTER_ID}-zepp-datanode$(ZEPP) container"
	@if [ -z "`docker ps -a --filter="name=${CLUSTER_ID}-zepp-datanode$(ZEPP)" | grep -v CONTAINER`" ]; then \
		docker run -itd --net=$(NETWORK) --hostname=${CLUSTER_ID}-zepp-datanode$(ZEPP) \
			--name=${CLUSTER_ID}-zepp-datanode$(ZEPP) -e NAMENODE=${CLUSTER_ID}-namenode \
			--volumes-from ${CLUSTER_ID}-data jpatel4pivotal/hdb2:$(OS_VERSION); \
	else \
		echo "${CLUSTER_ID}-zepp-datanode$(ZEPP) container already exist!"; \
	fi

run-scdf-container:
	@echo "run ${CLUSTER_ID}-scdf-datanode$(SCDF) container"
	@if [ -z "`docker ps -a --filter="name=${CLUSTER_ID}-scdf-datanode$(SCDF)" | grep -v CONTAINER`" ]; then \
		docker run -itd --net=$(NETWORK) --hostname=${CLUSTER_ID}-scdf-datanode$(SCDF) \
			--name=${CLUSTER_ID}-scdf-datanode$(SCDF) -e NAMENODE=${CLUSTER_ID}-namenode \
			--volumes-from ${CLUSTER_ID}-data jpatel4pivotal/hdb2:$(OS_VERSION); \
	else \
		echo "${CLUSTER_ID}-scdf-datanode$(SCDF) container already exist!"; \
	fi

start:
	@make -f $(THIS_MAKEFILE_PATH) start-hdfs
	@echo 'run "docker exec -it ${CLUSTER_ID}-namenode bash" to attach to ${CLUSTER_ID}-namenode node'

start-hdfs:
	@make -f $(THIS_MAKEFILE_PATH) start-namenode-container
	@i=1;\
	while [ $$i -le $(NDATANODES) ] ; do \
		make -f $(THIS_MAKEFILE_PATH) CUR_DATANODE=$$i start-datanode-container; \
		i=$$((i+1)); \
	done
	@echo "Done!"

start-namenode-container:
	@echo "start ${CLUSTER_ID}-namenode container"
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-namenode" | grep -v CONTAINER`" ]; then \
		docker start ${CLUSTER_ID}-namenode; \
	else \
		echo "${CLUSTER_ID}-namenode container does not exist!" && exit 1; \
	fi

start-datanode-container:
	@echo "start ${CLUSTER_ID}-datanode$(CUR_DATANODE) container"
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-datanode$(CUR_DATANODE)" | grep -v CONTAINER`" ]; then \
		docker start ${CLUSTER_ID}-datanode$(CUR_DATANODE); \
	else \
		echo "${CLUSTER_ID}-datanode$(CUR_DATANODE) container does not exist!" && exit 1; \
	fi

stop:
	@make -f $(THIS_MAKEFILE_PATH) stop-hdfs

stop-hdfs:
	@make -f $(THIS_MAKEFILE_PATH) stop-namenode-container
	@i=1; \
	while [ $$i -le $(NDATANODES) ] ; do \
		make -f $(THIS_MAKEFILE_PATH) CUR_DATANODE=$$i stop-datanode-container; \
		i=$$((i+1)); \
	done
	@if [ ${ZEPP} = 1 ] ; then make -f $(THIS_MAKEFILE_PATH) stop-zepp-container ; fi
	@if [ ${SCDF} = 1 ] ; then make -f $(THIS_MAKEFILE_PATH) stop-scdf-container ; fi
	@echo "Done!"

stop-namenode-container:
	@echo "stop ${CLUSTER_ID}-namenode container"
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-namenode" | grep -v CONTAINER`" ]; then \
		docker stop -t 0 ${CLUSTER_ID}-namenode; \
	else \
		echo "${CLUSTER_ID}-namenode container does not exist!"; \
	fi

stop-datanode-container:
	@echo "stop ${CLUSTER_ID}-datanode$(CUR_DATANODE) container"
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-datanode$(CUR_DATANODE)" | grep -v CONTAINER`" ]; then \
		docker stop -t 0 ${CLUSTER_ID}-datanode$(CUR_DATANODE); \
	else \
		echo "${CLUSTER_ID}-datanode$(CUR_DATANODE) container does not exist!"; \
	fi

stop-zepp-container:
	@echo "stop ${CLUSTER_ID}-zepp-datanode$(ZEPP) container"
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-zepp-datanode$(ZEPP)" | grep -v CONTAINER`" ]; then \
		docker stop -t 0 ${CLUSTER_ID}-zepp-datanode$(ZEPP); \
	else \
		echo "${CLUSTER_ID}-zepp-datanode$(ZEPP) container does not exist!"; \
	fi

stop-scdf-container:
	@echo "stop ${CLUSTER_ID}-scdf-datanode$(SCDF) container"
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-scdf-datanode$(SCDF)" | grep -v CONTAINER`" ]; then \
		docker stop -t 0 ${CLUSTER_ID}-scdf-datanode$(SCDF); \
	else \
		echo "${CLUSTER_ID}-scdf-datanode$(SCDF) container does not exist!"; \
	fi

remove-hdfs:
	@make -f $(THIS_MAKEFILE_PATH) remove-namenode-container
	@i=1; \
	while [ $$i -le $(NDATANODES) ] ; do \
		make -f $(THIS_MAKEFILE_PATH) CUR_DATANODE=$$i remove-datanode-container; \
		i=$$((i+1)); \
	done
	@echo "Done!"

remove-namenode-container:
	@echo "make ${CLUSTER_ID}-namenode container"
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-namenode" | grep -v CONTAINER`" ]; then \
		docker rm ${CLUSTER_ID}-namenode; \
	else \
		echo "${CLUSTER_ID}-namenode container does not exist!"; \
	fi

remove-datanode-container:
	@echo "make ${CLUSTER_ID}-datanode$(CUR_DATANODE) container"
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-datanode$(CUR_DATANODE)" | grep -v CONTAINER`" ]; then \
		docker rm ${CLUSTER_ID}-datanode$(CUR_DATANODE); \
	else \
		echo "${CLUSTER_ID}-datanode$(CUR_DATANODE) container does not exist!"; \
	fi

remove-zepp-container:
	@echo "make ${CLUSTER_ID}-zepp-datanode$(ZEPP) container"
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-zepp-datanode$(ZEPP)" | grep -v CONTAINER`" ]; then \
		docker rm ${CLUSTER_ID}-zepp-datanode$(ZEPP); \
	else \
		echo "${CLUSTER_ID}-zepp-datanode$(ZEPP) container does not exist!"; \
	fi

remove-scdf-container:
	@echo "make ${CLUSTER_ID}-scdf-datanode$(SCDF) container"
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-scdf-datanode$(SCDF)" | grep -v CONTAINER`" ]; then \
		docker rm ${CLUSTER_ID}-scdf-datanode$(SCDF); \
	else \
		echo "${CLUSTER_ID}-scdf-datanode$(SCDF) container does not exist!"; \
	fi

remove-data:
	@echo remove ${CLUSTER_ID}-data container
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-data" | grep -v CONTAINER`" ]; then \
		docker rm ${CLUSTER_ID}-data; \
	else \
		echo "${CLUSTER_ID}-data container does not exist!"; \
	fi
# Commenting out lines below from wangzw's MakeFile
#pull:
#	@echo latest images
#	docker pull mayjojo/hawq-devel:$(OS_VERSION)
#	docker pull mayjojo/hawq-test:$(OS_VERSION)

clean:
	@make -f $(THIS_MAKEFILE_PATH) stop 2>&1 >/dev/null || true
	@make -f $(THIS_MAKEFILE_PATH) remove-hdfs 2>&1 >/dev/null || true
	@make -f $(THIS_MAKEFILE_PATH) remove-zepp-container 2>&1 >/dev/null || true
	@make -f $(THIS_MAKEFILE_PATH) remove-scdf-container 2>&1 >/dev/null || true
	@echo "Done!"

distclean:
	@make -f $(THIS_MAKEFILE_PATH) stop 2>&1 >/dev/null || true
	@make -f $(THIS_MAKEFILE_PATH) remove-hdfs 2>&1 >/dev/null || true
	@make -f $(THIS_MAKEFILE_PATH) remove-zepp-container 2>&1 >/dev/null || true
	@make -f $(THIS_MAKEFILE_PATH) remove-scdf-container 2>&1 >/dev/null || true
	@make -f $(THIS_MAKEFILE_PATH) remove-data 2>&1 >/dev/null || true
	@if [ ! -z "`docker network ls 2>/dev/null | grep $(NETWORK)`" ]; then \
	        echo remove network $(NETWORK); \
	        docker network rm $(NETWORK) 2>&1 >/dev/null || true; \
	fi
	@echo "Done!"
