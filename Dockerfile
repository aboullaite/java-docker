FROM adoptopenjdk/openjdk11:jdk-11.0.2.9 as build
COPY target/netty-example-1.0-SNAPSHOT.jar /opt/app/
# Creating A List Of Application Classes
RUN ["java", "-XX:DumpLoadedClassList=classes.lst", "-jar", "/opt/app/netty-example-1.0-SNAPSHOT.jar"]
# Creating An Application Class-Data Archive
RUN ["java", "-Xshare:dump", "-XX:DumpLoadedClassList=classes.lst", "XX:SharedArchiveFile=/opt/app/app-cds.jsa", "--class-path", "/opt/app/netty-example-1.0-SNAPSHOT.jar"]

FROM adoptopenjdk/openjdk11:jdk-11.0.2.9
COPY --from=build /opt/app /opt/app
# Using An Application Class-Data Archive
CMD ["java","-Xshare:on", "XX:SharedArchiveFile=/opt/app/app-cds.jsa", "-jar", "/opt/app/netty-example-1.0-SNAPSHOT.jar"]
