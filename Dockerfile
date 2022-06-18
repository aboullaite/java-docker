FROM amazoncorretto:18 as build
COPY target/netty-example-1.0-SNAPSHOT.jar /opt/app/app.jar

### Before Java 13 ###
# Creating A List Of Application Classes
# RUN ["java", "-XX:DumpLoadedClassList=classes.lst", "-jar", "/opt/app/app.jar"]
# Creating An Application Class-Data Archive
# RUN ["java", "-XX:+UseAppCDS", "-Xshare:dump", "-XX:DumpLoadedClassList=classes.lst", "-XX:SharedArchiveFile=/opt/app/app-cds.jsa", "--class-path", "/opt/app/app.jar"]

### Java 13+
RUN ["java", "-XX:ArchiveClassesAtExit=/opt/app/app-cds.jsa", "-jar", "/opt/app/app.jar"]


FROM amazoncorretto:18
COPY --from=build /opt/app /opt/app
# Using An Application Class-Data Archive
CMD ["java","-Xshare:on", "-XX:SharedArchiveFile=/opt/app/app-cds.jsa", "-jar", "/opt/app/app.jar"]
