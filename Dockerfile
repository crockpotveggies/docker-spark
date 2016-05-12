FROM bernieai/docker-hadoop:2.6.0
MAINTAINER crockpotveggies

# variables
ENV SPARK_VERSION      1.6.1
ENV SCALA_VERSION      2.10.6
ENV SPARK_BIN_VERSION  $SPARK_VERSION-bin-hadoop2.6
ENV SPARK_HOME         /usr/local/spark
ENV SCALA_HOME         /usr/local/scala
ENV PATH               $PATH:$SPARK_HOME/bin:$SCALA_HOME/bin


# install dependencies
RUN apt-get install -y git openssh-server openssh-client
RUN locale-gen en_US en_US.UTF-8

# Install OpenBLAS
RUN apt-get install -y libopenblas-dev

# now update the library system:
RUN echo /opt/OpenBLAS/lib >  /etc/ld.so.conf.d/openblas.conf
RUN ldconfig
ENV LD_LIBRARY_PATH=/opt/OpenBLAS/lib:$LD_LIBRARY_PATH

# Install Scala
RUN wget http://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz && \
    tar -zxf /scala-$SCALA_VERSION.tgz -C /usr/local/ && \
    ln -s /usr/local/scala-$SCALA_VERSION $SCALA_HOME && \
    rm /scala-$SCALA_VERSION.tgz

# install Spark for Hadoop 2.6.0
RUN wget http://d3kbcqa49mib13.cloudfront.net/spark-$SPARK_BIN_VERSION.tgz && \
    tar -zxf /spark-$SPARK_BIN_VERSION.tgz -C /usr/local/ && \
    ln -s /usr/local/spark-$SPARK_BIN_VERSION $SPARK_HOME && \
    rm /spark-$SPARK_BIN_VERSION.tgz
#RUN mkdir $SPARK_HOME/yarn-remote-client
ADD yarn-remote-client $SPARK_HOME/yarn-remote-client

ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV PATH $PATH:$SPARK_HOME/bin:$HADOOP_PREFIX/bin

RUN $BOOTSTRAP && $HADOOP_PREFIX/bin/hadoop dfsadmin -safemode leave && hadoop fs -put $SPARK_HOME-$SPARK_VERSION-bin-hadoop2.6/lib /spark

# update boot script
COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root.root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

#ADD yarn-remote-client/slaves $HADOOP_PREFIX/etc/hadoop/slaves

# expose ports for Spark and Hadoop systems
EXPOSE 8088 8042 4040

ENTRYPOINT ["/etc/bootstrap.sh"]
