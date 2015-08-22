FROM centos:latest

ENV ZOOKEEPER_VERSION 3.4.6
EXPOSE 2181 2888 3888

RUN yum update -y
RUN rpm --rebuilddb && yum install -y java-1.7.0-openjdk-headless wget tar && yum clean all \
    && wget -q -O - http://apache.mirrors.pair.com/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz | tar -xzf - -C /opt \
    && mv /opt/zookeeper-${ZOOKEEPER_VERSION} /opt/zookeeper

ENV PATH /opt/zookeeper/bin:$PATH
WORKDIR /opt/zookeeper

COPY config-and-run.sh ./bin/
COPY zoo.cfg ./conf/
COPY log4j.properties ./conf/

RUN groupadd zookeeper && \
    useradd -g zookeeper zookeeper

RUN chmod a+x ./bin/config-and-run.sh && \
    mkdir -p /zookeeper_data/{data,txnlog,log} && \
    chown -R zookeeper.zookeeper /opt/zookeeper /zookeeper_data && \
    chmod o+w -R /opt/zookeeper /zookeeper_data

VOLUME ["/zookeeper_data/data","/zookeeper_data/txnlog","/zookeeper_data/log"]

#USER zookeeper

CMD ["/opt/zookeeper/bin/config-and-run.sh"]