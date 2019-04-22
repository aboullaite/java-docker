FROM adoptopenjdk/openjdk11:jdk-11.0.2.9 AS build
# jdeps can help identify which modules an application uses
RUN ["jlink", "--compress=2", \
     "--module-path", "${JAVA_HOME}/jmods", \
     "--add-modules", "java.base,java.logging,java.naming,java.xml,jdk.sctp,jdk.unsupported", \
     "--strip-debug", "--no-header-files", "--no-man-pages", \
     "--output", "/netty-runtime"]
RUN ["ls", "/netty-runtime"]

FROM gcr.io/distroless/base
COPY --from=build  /netty-runtime /opt/jdk
COPY --from=build /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/libz.so.1
ENV PATH=$PATH:/opt/jdk/bin
COPY target/netty-example-1.0-SNAPSHOT.jar /opt/app/
CMD ["java", "-showversion", "-jar", "/opt/app/netty-example-1.0-SNAPSHOT.jar"]