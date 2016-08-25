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

# BUILD Instructions Simple

```
git clone https://github.com/jpatel-pivotal/hdb-docker.git
cd hdb-docker/hdb2
make run
```

**Note**: This script will configure 1 NN, 3 DNs using a pre-built image that it will download from Docker Hub. The NN is Apache HAWQ (incubating) Master and DNs are Apache HAWQ (incubating) segments.

Once you have 4 containers running, connect to the NN container as the output of make run shows. tail -f ~/start_hdb.log to see Apache HAWQ (incubating) processes starting up. It usually takes a few minutes before Apache HAWQ (incubating) and PXF processes are online. Alternatively you could check for running postgres and pxf using ps.

To start over, use the commands below:

```
make stop
make clean
make distclean
make run
```

# <a name="buildadv"></a> BUILD Instructions Advanced

**Note**: If you want to have Apache HAWQ (incubating) along with Spring Cloud Data Flow and Zeppelin, then follow the steps below. Keep in mind that this will spin up a total of 7 containers (so 3 more containers than the simple case). The Advanced version uses more resources on your Docker host so provision accordingly.

```
git clone https://github.com/jpatel-pivotal/hdb-docker.git
cd hdb-docker/hdb2
make run ZEPP=1 SCDF=1
```

**Note**: This script will configure 1 NN, 5 DNs using a pre-built image that it will download from Docker Hub. The NN is Apache HAWQ (incubating) Master and DN[1-3] are Apache HAWQ (incubating) segments.

Once you have 4 containers running, connect to the NN container as the output of make run shows. tail -f ~/start_hdb.log to see Apache HAWQ (incubating) processes starting up. It usually takes a few minutes before Apache HAWQ (incubating) and PXF processes are online. Alternatively you could check for running postgres and pxf using ps.

You should also have 1 Zeppelin, 1 kafka and 1 Spring Cloud Data Flow containers.

# Clean up and start the Advanced environment up again

To start over with a clean environment if you ran the [advanced build commands](#buildadv), use the commands below:

```
make stop ZEPP=1 SCDF=1
make clean ZEPP=1 SCDF=1
make distclean ZEPP=1 SCDF=1
make run ZEPP=1 SCDF=1
```

# Restart Advanced environemnt up again

To restart the containers if you ran the [advanced build commands](#buildadv), use the command below:

```
make restart ZEPP=1 SCDF=1
```

# Connect to a container

To connect to any container use the command below:

```
docker exec -it <container-name> bash
```

Replace **<container-name>** in the command above with the name of the container you want to connect to.

# Connecting to Apache HAWQ (incubating)

Once processes have started up you can use the commands below to connect to the NN container and then running SQL queries in Apache HAWQ (incubating)

```
docker exec -it centos7-namenode bash
[gpadmin@centos7-namenode data]$ psql
gpadmin=# select version();
```
# Connecting to Zeppelin UI

If you ran the [advanced build commands](#buildadv), then you can use the URL below to connect to Zeppelin's UI

```
http://<IP or FQDN of Docker HOST>:9080
```
There are interpreters that are pre-installed for zeppelin. You must create an instance of the postgresql interpreter and configure it in order to use ``%psql`` binding in your notebooks. All you have to do is replace ``localhost`` in the ``postgresql.url`` property with the name of the NN (``centos7-namenode``). All other defaults should work out of the box.

The path to install-interpreter script is: ``/usr/local/zeppelin-*/bin/install-interpreter.sh``
Below is a list of the pre-installed interpreters:
1. shell
1. python
1. postgresql
1. file
1. angular
1. md
1. jdbc
1. elasticsearch
1. hbase  

For details on Zeppelin, please follow the [documentation](https://zeppelin.apache.org/docs/0.6.1/).

# Connecting to Spring Cloud Data Flow dashboard and starting up the Shell

If you ran the [advanced build commands](#buildadv), then you can use the url below to connect to the SCDF Dashboard.

```
http://<IP or FQDN of Docker HOST>:9393/dashboard
```

The SCDF shell can be invoked using the command below:

```
java -jar /data/spring-cloud-dataflow-shell-*.BUILD-SNAPSHOT.jar
```

For details on how to use the shell, please refer to SCDF [documentation](http://docs.spring.io/spring-cloud-dataflow/docs/1.0.1.BUILD-SNAPSHOT/reference/htmlsingle).

### Thank You
The building blocks for this code are from wangzw's Docker effort that can be found at: https://hub.docker.com/r/mayjojo/hawq-devel/
I enhanced it and added in components like Apache HAWQ (incubating), PXF, PL/* languages, MADLib, Zeppelin, Spring Cloud Data Flow, etc.
