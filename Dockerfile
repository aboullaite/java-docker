FROM alpine:3.10 AS build
ENV JAVA_HOME /opt/jdk
ENV PATH $JAVA_HOME/bin:$PATH
ADD https://download.java.net/java/early_access/alpine/27/binaries/openjdk-13-ea+27_linux-x64-musl_bin.tar.gz $JAVA_HOME/openjdk.tar.gz
RUN tar --extract --file $JAVA_HOME/openjdk.tar.gz --directory "$JAVA_HOME" --strip-components 1; \
	rm $JAVA_HOME/openjdk.tar.gz;
# jdeps can help identify which modules an application uses
RUN ["jlink", "--compress=2", \
     "--module-path", "/opt/jdk/jmods/", \
     "--add-modules", "java.base,java.logging,java.naming,java.xml,jdk.sctp,jdk.unsupported", \
     "--no-header-files", "--no-man-pages", \
     "--output", "/netty-runtime"]

FROM alpine:3.10
COPY --from=build  /netty-runtime /opt/jdk
ENV PATH=$PATH:/opt/jdk/bin
COPY target/netty-example-1.0-SNAPSHOT.jar /opt/app/
CMD ["java", "-showversion", "-jar", "/opt/app/netty-example-1.0-SNAPSHOT.jar"]