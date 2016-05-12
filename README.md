Apache Spark on Docker
==========

Published on [Docker Hub](https://hub.docker.com/r/bernieai/docker-spark/).

This repository contains a Docker file to build a Docker image with Apache Spark using YARN and includes Hadoop support. This image is originally based on SequenceIQ's [hadoop-docker](https://github.com/sequenceiq/hadoop-docker) and migrated to Ubuntu 14.04.4, available on [GitHub](https://github.com/crockpotveggies/docker-hadoop). The base Hadoop Docker image is also available as a published [Docker image](https://hub.docker.com/r/bernieai/docker-hadoop/).

### Pull the image from Docker Repository
```
docker pull bernieai/docker-spark:latest
```

### Building the image
```
docker build --rm -t bernieai/docker-spark:latest .
```

### Pre-flight setup
Note that you will have to address some prerequisites in Hadoop in order to deploy this image correctly. You will designate a "master" node (the container hostname must be `master.cluster`) that will need privileges to SSH into each slave node. This is best achieved using key-based authentication. Although some instructions [here](https://allthingshadoop.com/2010/04/20/hadoop-cluster-setup-ssh-key-authentication/) will give you background on how to operate this manually, the base image for **docker-hadoop** automatically generates a key for you.

Since a public key is already available on the master node, you will need to copy its contents to the `~/.ssh/authorized_keys` file on other machines. Once this is completed, your cluster will be ready to log into other machines. Remember that if you restart your master node, your keys may regenerate themselves and you'll need to copy them again.


**This image comes with a default key.** You will find it printed in the logs via `docker logs container_id`. It is strongly suggested you remove the default key and replace it with your own. You will need this key in order to SSH into the container.

You will want to follow these general steps to set up your cluster:
* Set up all of your slaves *before* starting the master
* In one of your slaves, visit the logs to obtain your SSH key, and save it where you will need it
* Start the master container
* **Optional:** swap out the default SSH keys with your own
* Add all slaves to the master's `/etc/hosts`
* Check that the slaves listed in `$HADOOP_PREFIX/etc/hadoop/slaves` are up-to-date
* In master, start DFS and YARN using `$HADOOP_PREFIX/sbin/start-yarn.sh; $HADOOP_PREFIX/sbin/start-dfs.sh` 

### Running the image

* if using boot2docker make sure your VM has more than 2GB memory
* in your /etc/hosts file make sure you define 'master.cluster' to make it easier to access your sandbox UI on the master node and so slaves can access the ResourceManager

When booting up a master node with ResourceManager and NameNode:
```
docker run -dit -p 19888:19888 -p 8030:8030 -p 8031:8031 -p 8032:8032 -p 8033:8033 -p 8040:8040 -p 8042:8042 -p 8088:8088 -p 4040:4040 -p 50010:50010 -p 50020:50020 -p 50070:50070 -p 50075:50075 -p 50090:50090 -p 8020:8020 -p 9000:9000 -p 2122:2122 -p 49707:49707 -h master.cluster bernieai/docker-spark:latest -d
```

When booting up a slave/worker:
```
docker run -dit -p 19888:19888 -p 8030:8030 -p 8031:8031 -p 8032:8032 -p 8033:8033 -p 8040:8040 -p 8042:8042 -p 8088:8088 -p 4040:4040 -p 50010:50010 -p 50020:50020 -p 50070:50070 -p 50075:50075 -p 50090:50090 -p 8020:8020 -p 9000:9000 -p 2122:2122 -p 49707:49707 -h slave1.cluster bernieai/docker-spark:latest -d
```

Once your nodes are up and running, you can then login via SSH:
```
ssh -p 2122 user@container_ip
```


### Versions
```
Hadoop 2.6.0 and Apache Spark v1.6.1 on Ubuntu 14.04.4 
```

### Testing

There are two deploy modes that can be used to launch Spark applications on YARN.

#### YARN-client mode

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
