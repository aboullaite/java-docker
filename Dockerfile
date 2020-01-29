FROM oracle/graalvm-ce:19.3.1-java11 AS build
RUN gu install native-image
COPY target/netty-example-1.0-SNAPSHOT.jar /opt/app/
WORKDIR /opt/app/
RUN native-image -jar ./netty-example-1.0-SNAPSHOT.jar 

FROM scratch
COPY --from=build  /opt/app/netty-native /
CMD ["/netty-native"]