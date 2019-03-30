FROM adoptopenjdk/openjdk11:jdk-11.0.2.9
COPY target/netty-example-1.0-SNAPSHOT.jar /opt/app/
CMD ["java", "-jar", "/opt/app/netty-example-1.0-SNAPSHOT.jar"]
