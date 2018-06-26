package com.sirolf2009.muse.ui

import com.fxgraph.layout.RandomLayout
import com.sirolf2009.muse.core.MStream
import com.sirolf2009.muse.core.MStreamBuilder
import java.net.InetAddress
import java.util.Properties
import javafx.application.Application
import javafx.scene.Scene
import javafx.stage.Stage
import org.apache.kafka.clients.consumer.ConsumerConfig
import org.apache.kafka.common.serialization.Serdes
import org.apache.kafka.streams.KafkaStreams
import org.apache.kafka.streams.StreamsConfig

class MuseUI extends Application {
	
	def static void main(String[] args) throws Exception {
        launch(args)
    }

    override void start(Stage stage) throws Exception {
    	val props = new Properties() => [
			put(StreamsConfig.APPLICATION_ID_CONFIG, "fucking-cancer")
			put(StreamsConfig.CLIENT_ID_CONFIG, InetAddress.getLocalHost().getHostName())
			put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092")
			put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.Long().getClass().getName())
			put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.Double().getClass().getName())
			put(StreamsConfig.consumerPrefix(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG), "earliest");
			put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
		]
		val builder = new MStreamBuilder()
		
		val MStream<Long, Double> stream = builder.stream("prices")
		stream.mapValues[it * 2].mapValues[it / 2].foreach[key, value| println('''«key», «value»''')]
		stream.mapValues[it * 2].mapValues[it / 2].foreach[key, value|]
		
//		val MStream<String, Integer> stream2 = builder.stream("random")
//		stream2.mapValues[it * 2].mapValues[it / 2].foreach[key, value|]
		
		val topology = builder.build()
		val streams = new KafkaStreams(topology, props)
		streams.cleanUp()
		streams.start()
		Runtime.getRuntime().addShutdownHook(new Thread[streams.close()])
    	val graph = builder.getGraph()
    	graph.endUpdate()
    	graph.layout(new RandomLayout())

        val scene = new Scene(graph.getScrollPane(), 1200, 600)
		scene.getStylesheets().add(getClass().getResource("/application.css").toExternalForm())

        stage.setTitle("Hello JavaFX and Maven")
        stage.setScene(scene)
        stage.show()
    }
	
}