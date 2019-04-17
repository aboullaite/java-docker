FROM oracle/graalvm-ce:1.0.0-rc15 AS build
COPY target/netty-example-1.0-SNAPSHOT.jar /opt/app/
COPY dep/svm-1.0.0*.jar ${JAVA_HOME}/jre/lib/svm/builder/svm.jar
WORKDIR /opt/app/
RUN native-image --verbose -jar ./netty-example-1.0-SNAPSHOT.jar --static --delay-class-initialization-to-runtime=io.netty.handler.codec.http.HttpObjectEncoder -H:ReflectionConfigurationResources=netty_reflection_config.json -O1 -H:Name=netty-native 

FROM scratch
COPY --from=build  /opt/app/netty-native /
CMD ["/netty-native"]