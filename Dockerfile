FROM adoptopenjdk/openjdk11:jdk-11.0.2.9 As build
RUN  apt-get update && apt-get -y upgrade && apt-get -y install build-essential
COPY target/netty-example-1.0-SNAPSHOT.jar /opt/app/
COPY dep/ /opt/app/dep/
COPY aot.cfg /opt/app/
## aot.cfg is containing all methods that have been touched at run time (-XX:+LogTouchedMethods & -XX:+PrintTouchedMethodsAtExit)
RUN jaotc --output /opt/app/netty-example.so --compile-commands /opt/app/aot.cfg --module java.base --jar /opt/app/netty-example-1.0-SNAPSHOT.jar -J-cp -J"./:/opt/app/dep/*" --info

FROM adoptopenjdk/openjdk11:jdk-11.0.2.9
COPY --from=build  /opt/app/netty-example.so /opt/app/
COPY --from=build  /opt/app/netty-example-1.0-SNAPSHOT.jar /opt/app/
CMD ["java", "-XX:AOTLibrary=/opt/app/netty-example.so", "-jar", "/opt/app/netty-example-1.0-SNAPSHOT.jar"]