# hdb-docker

This is intended for dev/test purposes only. If you want a quick way to test a theory or familiarize yourself with core Apache HAWQ (incubating) functionality without all the other eco-system components, this is a good starting point.

This repository contains a lean and quick Apache HAWQ Docker Image that sets up 1 NameNode and 3 DataNode containers with Apache HAWQ (incubating) installed.

Apache HAWQ (incubating) has the following features enabled:

-ORCA
-PL/python
-PL/R
-MADLib

External data Query Framework or PXF is also installed and enabled.


# Prerequisites
1. Installed and Running Docker on linux or docker-machine on OSX
1. At least > 8GB RAM
1. At least > 16GB Disk Space  

# BUILD Instructions

1. git clone this repo
1. cd hdb-docker/hdb2
1. make run (this will configure 1 NN, 3 DNs using a pre-built image that it will download from Docker Hub. The NN is Apache HAWQ (incubating) Master and DNs are Apache HAWQ (incubating) segments)

*Note*: Once you have 4 containers running, connect to the NN container as the output of make run shows. tail -f ~/start_hdb.log to see Apache HAWQ (incubating) processes starting up. It usually takes a few minutes before Apache HAWQ (incubating) and PXF processes are online. Alternatively you could check for running postgres and pxf using ps.

To start over, use the commands below:

1. make stop
1. make clean
1. make distclean
1. make run

#Thank You
The building blocks for this code are from wangzw's Docker effort that can be found at: https://hub.docker.com/r/mayjojo/hawq-devel/
I enhanced it and added in components like Apache HAWQ (incubating), PXF, PL/* languages, MADLib, etc.
