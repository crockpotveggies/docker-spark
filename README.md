Apache Spark on Docker
==========


This repository contains a Docker file to build a Docker image with Apache Spark. This Docker image depends on [docker-hadoop](https://github.com/sequenceiq/hadoop-docker), available at [GitHub](https://github.com/crockpotveggies/docker-hadoop) page.
The base Hadoop Docker image is also available as an official [Docker image](https://registry.hub.docker.com/u/bernieai/docker-hadoop/).

### Pull the image from Docker Repository
```
docker pull bernieai/docker-spark:latest
```

### Building the image
```
docker build --rm -t bernieai/docker-spark:latest .
```

### Running the image

* if using boot2docker make sure your VM has more than 2GB memory
* in your /etc/hosts file make sure you define 'master.cluster' to make it easier to access your sandbox UI on the master node and so slaves can access the ResourceManager

When booting up a master node with ResourceManager and NameNode
```
docker run -it -p 19888:19888 -p 8030:8030 -p 8031:8031 -p 8032:8032 -p 8033:8033 -p 8040:8040 -p 8042:8042 -p 8088:8088 -p 4040:4040 -p 50010:50010 -p 50020:50020 -p 50070:50070 -p 50075:50075 -p 50090:50090 -p 8020:8020 -p 9000:9000 -h master.cluster bernieai/docker-spark:latest bash
```

When booting up a slave/worker:
```
docker run -it -p 19888:19888 -p 8030:8030 -p 8031:8031 -p 8032:8032 -p 8033:8033 -p 8040:8040 -p 8042:8042 -p 8088:8088 -p 4040:4040 -p 50010:50010 -p 50020:50020 -p 50070:50070 -p 50075:50075 -p 50090:50090 -p 8020:8020 -p 9000:9000 -h slave1.cluster bernieai/docker-spark:latest bash
```

Or simply:
```
docker run -d -h sandbox bernieai/docker-spark:latest -d
```

### Versions
```
Hadoop 2.6.0 and Apache Spark v1.6.1 on Centos 
```

## Testing

There are two deploy modes that can be used to launch Spark applications on YARN.

### YARN-client mode

In yarn-client mode, the driver runs in the client process, and the application master is only used for requesting resources from YARN.

```
# run the spark shell
spark-shell \
--master yarn-client \
--driver-memory 1g \
--executor-memory 1g \
--executor-cores 1

# execute the the following command which should return 1000
scala> sc.parallelize(1 to 1000).count()
```
### YARN-cluster mode

In yarn-cluster mode, the Spark driver runs inside an application master process which is managed by YARN on the cluster, and the client can go away after initiating the application.

Estimating Pi (yarn-cluster mode):

```
# execute the the following command which should write the "Pi is roughly 3.1418" into the logs
# note you must specify --files argument in cluster mode to enable metrics
spark-submit \
--class org.apache.spark.examples.SparkPi \
--files $SPARK_HOME/conf/metrics.properties \
--master yarn-cluster \
--driver-memory 1g \
--executor-memory 1g \
--executor-cores 1 \
$SPARK_HOME/lib/spark-examples-1.6.0-hadoop2.6.0.jar
```

Estimating Pi (yarn-client mode):

```
# execute the the following command which should print the "Pi is roughly 3.1418" to the screen
spark-submit \
--class org.apache.spark.examples.SparkPi \
--master yarn-client \
--driver-memory 1g \
--executor-memory 1g \
--executor-cores 1 \
$SPARK_HOME/lib/spark-examples-1.6.0-hadoop2.6.0.jar
```
