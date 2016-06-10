# hdb-docker

Pivotal HDB 2.0 Docker Image

HDB 2.0 has the following features enabled:

-Orca
-PL/python
-PL/R
-MADLib

PXF is also installed and enabled
# Prerequisites
1. Installed and Running Docker on linux or docker-machine on OSX
1. At least > 8GB RAM
1. At least > 16GB Disk Space  

# BUILD Instructions

1. git clone this repo
1. cd hdb-docker/hdb2
1. make run (this will configure 1 NN, 3 DN using a pre-built image that it will download from Docker Hub. The NN is HDB Master and DNs are HDB segments)

*Note: Once you have 4 containers running, connect to the NN container as the output of make run shows. tail -f ~/start-hdb.log to see HDB processes starting up. It usually takes a few minutes before HDB and PXF processes are online. Alternatively you could check for running postgres and pxf using ps. 

To start over, use the commands below:

1. make stop
1. make clean
1. make distclean
1. make run

#Thank You
The building blocks this code s from wangzw's Docker effort that can be found at: https://hub.docker.com/r/mayjojo/hawq-devel/
I enhanced it and added in components like HDB, PXF, PL/* language, madlib, etc. 


