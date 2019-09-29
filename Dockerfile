FROM adoptopenjdk/openjdk13:jdk-13_33 AS build
# jdeps can help identify which modules an application uses
RUN ["jlink", "--compress=2", \
     "--module-path", "${JAVA_HOME}/jmods", \
     "--add-modules", "java.base,java.logging,java.naming,java.xml,jdk.sctp,jdk.unsupported", \
     "--strip-java-debug-attributes", "--no-header-files", "--no-man-pages", \
     "--output", "/netty-runtime"]

FROM gcr.io/distroless/base
COPY --from=build  /netty-runtime /opt/jdk
COPY --from=build /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/libz.so.1
ENV PATH=$PATH:/opt/jdk/bin
COPY target/netty-example-1.0-SNAPSHOT.jar /opt/app/app.jar
CMD ["java", "-showversion", "-jar", "/opt/app/netty-example-1.0-SNAPSHOT.jar"]