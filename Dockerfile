FROM adoptopenjdk/openjdk13:jdk-13.0.1_9-slim As build
RUN  apt-get update && apt-get -y upgrade && apt-get -y install build-essential
COPY target/netty-example-1.0-SNAPSHOT.jar /opt/app/app.jar
# aot.cfg is containing all methods that have been touched at run time (-XX:+LogTouchedMethods & -XX:+PrintTouchedMethodsAtExit)
# RUN java -XX:+UnlockDiagnosticVMOptions -XX:+LogTouchedMethods -XX:+PrintTouchedMethodsAtExit -jar /opt/app/app.jar
COPY dep/ /opt/app/dep/
COPY aot.cfg /opt/app/
RUN jaotc --output /opt/app/app-native.so --compile-commands /opt/app/aot.cfg --module java.base --jar /opt/app/app.jar -J-cp -J"./:/opt/app/dep/*" --info

FROM adoptopenjdk/openjdk13:adoptopenjdk/openjdk13:jdk-13.0.1_9-slim
COPY --from=build  /opt/app/app-native.so /opt/app/
COPY --from=build  /opt/app/app.jar /opt/app/
CMD ["java", "-XX:AOTLibrary=/opt/app/app-native.so", "-jar", "/opt/app/app.jar"]