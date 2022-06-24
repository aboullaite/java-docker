FROM ubuntu:22.04
ENV JAVA_HOME /opt/jdk
ENV PATH $JAVA_HOME/bin:$PATH
RUN apt-get update -y && apt-get install -y libnl-genl-3-200 curl
ADD "https://github.com/CRaC/openjdk-builds/releases/download/17-crac%2B2/jdk17-crac+2.tar.gz" \
 $JAVA_HOME/openjdk.tar.gz
RUN tar --extract --file $JAVA_HOME/openjdk.tar.gz --directory "$JAVA_HOME" --strip-components 1; \
    rm $JAVA_HOME/openjdk.tar.gz;
COPY target/netty-example-1.0-SNAPSHOT.jar /opt/app/app.jar
CMD ["java", "-XX:CRaCCheckpointTo=/opt/app/cr", "-jar", "/opt/app/app.jar"]
