package com.sirolf2009.muse.ui

import com.fxgraph.graph.Graph
import com.fxgraph.layout.AbegoTreeLayout
import com.sirolf2009.muse.core.MStreamBuilder
import com.sirolf2009.muse.ui.properties.LocalProperties
import javafx.application.Application
import javafx.scene.Scene
import javafx.stage.Stage
import org.apache.kafka.common.serialization.Serdes
import com.sirolf2009.muse.core.MKafkaStream
import com.sirolf2009.muse.core.MRXStream

class MuseExample extends Application {
	
	def static void main(String[] args) throws Exception {
        launch(args)
    }

    override void start(Stage stage) throws Exception {
    	val props = LocalProperties.withSerdes("example-application", Serdes.Long(), Serdes.Double())
		val builder = new MStreamBuilder(props)

		val MKafkaStream<Long, Double> stream = builder.stream("prices")
		stream.mapValues[it * 2].mapValues[it / 2].foreach[key, value| println('''«key», «value»''')]
		stream.mapValues[it * 2].mapValues[it / 2].foreach[key, value|]
		
		val MKafkaStream<String, Integer> stream2 = builder.stream("random")
		stream2.mapValues[it * 2].mapValues[it / 2].foreach[key, value|]
		
		val MRXStream<Integer> numbers = builder.stream("numbers", #[0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
		val numbers1Transformed = numbers.map("*2 ") [
			it * 2
		].map("/2") [
			it / 2
		]
		
		val MRXStream<Integer> numbers2 = builder.stream("numbers2", #[0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
		val numbers2Transformed = numbers2.map("*2 ") [
			it * 2
		].map("/2") [
			it / 2
		]
		
		numbers1Transformed.concatWith("merge", numbers2Transformed).map("*2")[it * 2]
		
		val streams = builder.build()
		streams.cleanUpAndStart()
    	val graph = new Graph(streams.getModel())
    	graph.endUpdate()

        val scene = new Scene(graph.getScrollPane(), 1200, 600)
		scene.getStylesheets().add(getClass().getResource("/application.css").toExternalForm())

        stage.setTitle("Hello JavaFX and Maven")
        stage.setScene(scene)
        stage.show()
        
    	graph.layout(new AbegoTreeLayout())
    }
	
}