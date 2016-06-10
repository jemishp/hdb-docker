# hdb-docker

Pivotal HDB 2.0 Docker Image

HDB 2.0 has the following features enabled:

-Orca
-PL/python
-PL/R
-MADLib

PXF is also installed and enabled

# BUILD Instructions

1. git clone this repo
1. cd hdb-docker/hdb2
1. make run

*Note: Once you have 4 containers running, connect to the NN container as the output of make run shows. tail -f ~/start-hdb.log to see HDB processes starting up. It usually takes a few minutes before HDB and PXF processes are online. Alternatively you could check for running postgres and pxf using ps. 

#Thank You
The building blocks this code s from wangzw's Docker effort that can be found at: https://hub.docker.com/r/mayjojo/hawq-devel/
I enhanced it and added in components like HDB, PXF, PL/* language, madlib, etc. 


