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

#Thank You
A lot of this code was borrowed from wangzw's Docker effort that can be found at: https://hub.docker.com/r/mayjojo/hawq-devel/
I enhanced it and added in components like HDB, PXF, PL/* language, madlib, etc. 


