FROM amazoncorretto:18-alpine as build
# jdeps can help identify which modules an application uses
RUN ["jlink", "--compress=2", \
    "--module-path", "/opt/jdk/jmods/", \
    "--add-modules", "java.base,java.logging,java.naming,java.xml,jdk.sctp,jdk.unsupported", \
    "--no-header-files", "--no-man-pages", \
    "--output", "/netty-runtime"]

FROM alpine:3.15
COPY --from=build  /netty-runtime /opt/jdk
ENV PATH=$PATH:/opt/jdk/bin
COPY target/netty-example-1.0-SNAPSHOT.jar /opt/app/
CMD ["java", "-showversion", "-jar", "/opt/app/netty-example-1.0-SNAPSHOT.jar"]