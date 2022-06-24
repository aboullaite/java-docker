package me.aboullaite.dockercon;

import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.Channel;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.handler.logging.LogLevel;
import io.netty.handler.logging.LoggingHandler;
import io.netty.channel.ChannelOption;
import io.netty.util.concurrent.Future;
import org.crac.Context;
import org.crac.Core;
import org.crac.Resource;

public class HelloWorld implements Resource {

    private final static int HTTP_PORT = 8090;
    private EventLoopGroup eventLoopGroup;
    private Channel ch;
    private Thread preventExitThread;

    public HelloWorld() throws Exception{
        eventLoopGroup = new NioEventLoopGroup();
        ch = startServer();
        Core.getGlobalContext().register(this);

    }

    private Channel startServer() throws InterruptedException {
    // Create and configure a new pipeline for a new channel.
    System.out.println("Starting Server ...");
        ServerBootstrap bootstrap = new ServerBootstrap()
            .option(ChannelOption.SO_BACKLOG, 1024)
            .group(eventLoopGroup)
            .handler(new LoggingHandler(LogLevel.INFO))
            .childHandler(new HttpServerInitializer())
            .channel(NioServerSocketChannel.class);
        return bootstrap.bind(HTTP_PORT).sync().channel();
    }

    public static void main(String[] args) throws Exception{
        new HelloWorld();

    }

    @Override
    public void beforeCheckpoint(Context<? extends Resource> context) throws Exception {
        System.out.println("Starting checkpoint...");
        ch.close();
        Future<?> elFuture = eventLoopGroup.shutdownGracefully();
        elFuture.syncUninterruptibly();
    }

    @Override
    public void afterRestore(Context<? extends Resource> context) throws Exception {
        System.out.println("Starting restore...");
        eventLoopGroup = new NioEventLoopGroup();
        ch = startServer();
    }
}
