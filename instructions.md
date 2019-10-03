Thiese instructions aim to show how Java 8u121 are not container aware, and highlight the improvements made to make the JVM honors cgroups Resource Limits:

1/ clone [Spring petclinic](https://github.com/spring-projects/spring-petclinic) repo
2/ Run `mvn clean package -DskipTests` to package the app and generate the jar file
3/ run command `docker-compose up -d` to start mysql instance
4/ put the `.dockerignore` in the source directory of the repo

### Test app behavior with java 8
The effort to make the JVM container aware was merged in Java 9 & 8u131. to demonstrate the old behavior, we run the app with an old version of java: 8u121! Since I'm using Docker for Mac, I've enabled Docker to use up to 8GB of RAM!

1/ put the `Dockerfile.java8` in the root of the Spring perclinic app. and build the image (`docker build -t aboullaite/sbj8 -f Dockerfile.java8`)
2/ run the created image with no constraint first: `docker run -p 8080:8080 dc/sbj8`
Note that I'm launching with 2 arguments:
 + `-XX:NativeMemoryTracking=summary` to enable memory tracking
 + `-XshowSettings:vm` to get the virtual machine settings
On my machine, the output of running the app is below, which shows that the JVM took the 1/4 of the availble memory (8G) by default!
```
VM settings:
    Max. Heap Size (Estimated): 1.73G
    Ergonomics Machine Class: server
    Using VM: Java HotSpot(TM) 64-Bit Server VM
```
3/ Now let's try to run the app limiting the memory to 250M: `docker run -p 8080:8080 -m 250M --name sb250 dc/sbj8`. On my machine the app doesn't succeed to start!
A quick inspect of the container show that the container received an OOM signal: `docker inspect sb250 -f '{{json .State}}'`. If you inspect the container log, you should see that the JVM doesn't detecte the memory limitation:
```
VM settings:
    Max. Heap Size (Estimated): 1.73G
    Ergonomics Machine Class: server
    Using VM: Java HotSpot(TM) 64-Bit Server VM
```

4/ So let's add more memory and make it 500M and re-run the container: `docker run -p 8080:8080 -m 500M --name sb500 dc/sbj8`. It survived on my machine.

To see if it will still working, we can hit it with some load: `ab -k -c 100 -n 1000 http://localhost:8080/`. It still survives. However the logs still says that the reserved heap size is 1.7GB! 

```
VM settings:
    Max. Heap Size (Estimated): 1.73G
    Ergonomics Machine Class: server
    Using VM: Java HotSpot(TM) 64-Bit Server VM
```
That's werid! Let's check what is hapenning inside the jvm: 
    $ `docker exec -it sb500 bash`
    $ `cd $JAVA_HOME/bin`
We're goind to use the jcm utility! The jcmd utility is used to send diagnostic command requests to the JVM, where these requests are useful for controlling Java Flight Recordings, troubleshoot, and diagnose JVM and Java Applications.
Running the jcmd without options shows the PID of runing process in the JVM.
    $ `./jcmd`
On my machine, the app had a PID of 1! To get  diagnostic command requests to JVM using jcmd utility:
    $ `./jcmd 1 help`
We're interested to diagnostic the memoty, so we run the command:
    $ `./jcmd 1 VM.native_memory scale=MB`

This shows how the JVM uses it's memory! Note that the total commited memory is more thatn 500M!!! What is hapenning ?
Running `docker stats sb500` shows that the're were a lot of read/write on the disk! that's a lot for an app that does nothing! The app is actually swapping, to effectively check that, let's re-run the container and disable the swapping: `docker run -p 8080:8080 -m 500M --memory-swappiness --name sb500 dc/sbj8` an the container is back to death. You can verify using `docker inspect` command!

### Test app behavior with java 11
1/ put the `Dockerfile.java11` in the root of the Spring perclinic app. and build the image (`docker build -t aboullaite/sbj11 -f Dockerfile.java11`)
2/ run the created image with no constraint first: `docker run -p 8080:8080 dc/sbj11`
On my machine, the output of running the app is below, which shows that the JVM took the 1/4 of the availble memory (8G) by default!
```
VM settings:
    Max. Heap Size (Estimated): 1.95G
    Using VM: OpenJDK 64-Bit Server VM
```
3/ Running the app with only 250M, survives on my machine this time
```
VM settings:
    Max. Heap Size (Estimated): 121.81M
    Using VM: OpenJDK 64-Bit Server VM
```
