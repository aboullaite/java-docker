FROM adoptopenjdk/openjdk11:jdk-11.0.2.9 As build
RUN  apt-get update && apt-get upgrade && apt-get -y install build-essential
COPY target/netty-example-1.0-SNAPSHOT.jar /opt/app/
COPY dep/ /opt/app/dep/
COPY touched.aotcfg /opt/app/
RUN jaotc --output /opt/app/netty-example.so --compile-for-tiered  --compile-commands /opt/app/aot.cfg --module java.base --jar /opt/app/netty-example-1.0-SNAPSHOT.jar -J-cp -J"./:/opt/app/dep/*" --info

FROM adoptopenjdk/openjdk11:jdk-11.0.2.9
COPY --from=build  /opt/app/netty-example.so /opt/app/
COPY --from=build  /opt/app/netty-example-1.0-SNAPSHOT.jar /opt/app/
CMD ["java", "-XX:AOTLibrary=/opt/app/netty-example.so", "-jar", "/opt/app/netty-example-1.0-SNAPSHOT.jar"]