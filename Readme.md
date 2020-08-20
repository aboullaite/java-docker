### Docker & Java

This repo contains demo materials for:

- Tips minimize java containers images
- Tricks for fast startup java apps running in containers
- gotchas and issues while running java apps in containers and the improvements that has been made

The repo is split into multiple branches, each contains a specific topic. The `Dockerfile`s uses the generated jar after running the build (`mvn clean package`). The build step could be integrated in the provided `Dockerfile`s, but it would slow the demoing the intention of this repo, so I kept it outside. Below branch details:

- `master`: simple netty app, running in a container
- `mod`: Using Project Jigsaw’s `jlink`, that offers the ability to produce a minimal JRE based on the modules our application requires.
- `alpine`: This uses the early access alpine build of java 13, based on project Portola: the community effort to port java to `musl`
- `cdc`: This showcase the class data sharing (CDS) feature. CDC offers dynamic sharing of data between multiple Java Virtual Machines (JVM), which helps to reduce the startup time and memory footprint.
- `aot`: Using Ahead Of Time compilation. It compiles the bytecode such that it is completely static which should lead to the fastest startup and initial execution speed.
- `graal`: This part uses graal VM to create native images for existing JVM-based applications.
- `sb`: This branch contains a simple instructions to run the [petclinic](https://github.com/spring-projects/spring-petclinic) application and test how it behaves running inside a java 8 docker container, and java 11!

### Benchmarking

the `bench.sh` run each container and print at the end the total size of the image + the time it takes for teh container to run! for me I named the images: `plain`, `cdc`,`aot`,`graal`, `alpine` and `mod`. I prefixed each of them with `dj`! Executing the scripts shows below results in my machine:

```
Image   size        Startup
plain    353.836MB   627 ms
mod      59.12MB     649 ms
alpine   47.0079MB   651 ms
aot      392.888MB   537 ms
cds      357.231MB   547 ms
graal    13.3264MB   3 ms
```
