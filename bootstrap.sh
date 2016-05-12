#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# altering the core-site configuration
sed s/HOSTNAME/$HOSTNAME/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml

# setting spark defaults
echo spark.yarn.jar hdfs:///spark/spark-assembly-1.6.1-hadoop2.6.0.jar > $SPARK_HOME/conf/spark-defaults.conf
cp $SPARK_HOME/conf/metrics.properties.template $SPARK_HOME/conf/metrics.properties

# N is the node number of the cluster
N=$SLAVE_SIZE

# change the slaves file
echo "master.cluster" > $HADOOP_PREFIX/etc/hadoop/slaves
i=1
while [ $i -lt $N ]
do
  echo "slave$i.cluster" >> $HADOOP_PREFIX/etc/hadoop/slaves
  ((i++))
done 

# make sure that our env variables are also in SSH
echo "Writing env variables to bash profile"
export >> /root/.bash_profile

# let the user know what their key is
echo "####################"
echo "Printing private key"
echo "####################"
cat ~/.ssh/id_rsa

echo "###################"
echo "Printing public key"
echo "###################"
cat ~/.ssh/id_rsa.pub

# start up required services
/usr/sbin/sshd
while true; do echo up and running; sleep 1; done
#$HADOOP_PREFIX/sbin/start-dfs.sh
#$HADOOP_PREFIX/sbin/start-yarn.sh


# continue with boot
#CMD=${1:-"exit 0"}
#if [[ "$CMD" == "-d" ]];
#then
#	service sshd stop
#	/usr/sbin/sshd -D -d
#else
#	/bin/bash -c "$*"
#fi
