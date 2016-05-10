FROM bernieai/hadoop-docker:2.6.0
MAINTAINER crockpotveggies

# set nameserver
RUN cat /etc/resolv.conf
RUN echo "search dns.google.com\nnameserver 8.8.8.8" > /etc/resolv.conf
RUN cat /etc/resolv.conf

# install dependencies
RUN yum -y update
RUN yum -y install git

# install blas
RUN mkdir ~/src && cd ~/src && \
  git clone https://github.com/xianyi/OpenBLAS && \
  cd ~/src/OpenBLAS && \
  make FC=gfortran && \
  make PREFIX=/opt/OpenBLAS install

# now update the library system:
RUN echo /opt/OpenBLAS/lib >  /etc/ld.so.conf.d/openblas.conf
RUN ldconfig
ENV LD_LIBRARY_PATH=/opt/OpenBLAS/lib:$LD_LIBRARY_PATH

# support for Hadoop 2.6.0
RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-1.6.1-bin-hadoop2.6.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-1.6.1-bin-hadoop2.6 spark
ENV SPARK_HOME /usr/local/spark
RUN mkdir $SPARK_HOME/yarn-remote-client
ADD yarn-remote-client $SPARK_HOME/yarn-remote-client

RUN $BOOTSTRAP && $HADOOP_PREFIX/bin/hadoop dfsadmin -safemode leave && $HADOOP_PREFIX/bin/hdfs dfs -put $SPARK_HOME-1.6.1-bin-hadoop2.6/lib /spark

ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV PATH $PATH:$SPARK_HOME/bin:$HADOOP_PREFIX/bin

# update boot script
COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root.root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

# expose ports for Spark and Hadoop systems
EXPOSE 8088 8042 4040

ENTRYPOINT ["/etc/bootstrap.sh"]
