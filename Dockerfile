FROM centos:centos7 as base

RUN yum update -y \
    && yum -y install vim wget rpm-build which tar git gcc java-11-openjdk-devel mysql \
    && yum clean all -y

ENV JAVA_HOME /usr/lib/jvm/java-openjdk
ENV MYSQL_CONNECTOR_JAVA_VERSION 5.1.41
ENV RANGER_HOME /opt/ranger
ENV RANGER_VERSION "release-ranger-2.1.0-trino"
ENV MAVEN_HOME /opt/maven
ENV MAVEN_VERSION 3.8.1
ENV MAVEN_OPTS "-Xmx2048m -XX:MaxMetaspaceSize=512m"

RUN wget -P /opt https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-$MYSQL_CONNECTOR_JAVA_VERSION.tar.gz \
    && tar -zxvf /opt/mysql-connector-java-$MYSQL_CONNECTOR_JAVA_VERSION.tar.gz -C /opt \
    && rm -f /opt/mysql-connector-java-$MYSQL_CONNECTOR_JAVA_VERSION.tar.gz \
    && ln -s /opt/mysql-connector-java-$MYSQL_CONNECTOR_JAVA_VERSION/mysql-connector-java-$MYSQL_CONNECTOR_JAVA_VERSION-bin.jar /opt/mysql-connector-java.jar

RUN mkdir $MAVEN_HOME \
    && export http_proxy=$http_proxy \
    && wget -P $MAVEN_HOME http://mirror.dsrg.utoronto.ca/apache/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz \
    && tar -xzvf $MAVEN_HOME/apache-maven-$MAVEN_VERSION-bin.tar.gz -C $MAVEN_HOME \
    && rm -f $MAVEN_HOME/apache-maven-$MAVEN_VERSION-bin.tar.gz

ADD . $RANGER_HOME
WORKDIR $RANGER_HOME

RUN $MAVEN_HOME/apache-maven-$MAVEN_VERSION/bin/mvn -DskipTests clean compile package -pl '!hive-agent' \
    && rm -rf ~/.m2 \
    && rm -rf $MAVEN_HOME
