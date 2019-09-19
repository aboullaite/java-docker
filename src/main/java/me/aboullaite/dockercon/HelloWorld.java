package me.aboullaite.dockercon;

import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.Channel;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.handler.logging.LogLevel;
import io.netty.handler.logging.LoggingHandler;
import io.netty.channel.ChannelOption;

public class HelloWorld {

    private final static int HTTP_PORT = 8090;

    public static void main(String[] args) throws Exception{

        EventLoopGroup eventLoopGroup = new NioEventLoopGroup();

        try {
            // Create and configure a new pipeline for a new channel.    
            ServerBootstrap bootstrap = new ServerBootstrap()
                    .option(ChannelOption.SO_BACKLOG, 1024)
                    .group(eventLoopGroup)
                    .handler(new LoggingHandler(LogLevel.INFO))
                    .childHandler(new HttpServerInitializer())
                    .channel(NioServerSocketChannel.class);

            Channel ch = bootstrap.bind(HTTP_PORT).sync().channel();
            System.exit(0);
            ch.closeFuture().sync();
        } finally {
            eventLoopGroup.shutdownGracefully();
        }
    }
}
