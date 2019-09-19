FROM oracle/graalvm-ce:19.2.0.1 AS build
COPY target/netty-example-1.0-SNAPSHOT.jar /opt/app/
WORKDIR /opt/app/
RUN gu install native-image
RUN native-image -jar ./netty-example-1.0-SNAPSHOT.jar 

FROM scratch
COPY --from=build  /opt/app/netty-native /
CMD ["/netty-native"]