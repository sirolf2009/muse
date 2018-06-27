package com.sirolf2009.muse.ui

import com.fxgraph.graph.Graph
import com.fxgraph.layout.AbegoTreeLayout
import com.sirolf2009.muse.core.MStream
import com.sirolf2009.muse.core.MStreamBuilder
import com.sirolf2009.muse.ui.properties.LocalProperties
import javafx.application.Application
import javafx.scene.Scene
import javafx.stage.Stage
import org.apache.kafka.common.serialization.Serdes

class MuseExample extends Application {
	
	def static void main(String[] args) throws Exception {
        launch(args)
    }

    override void start(Stage stage) throws Exception {
    	val props = LocalProperties.withSerdes("example-application", Serdes.Long(), Serdes.Double())
		val builder = new MStreamBuilder(props)

		val MStream<Long, Double> stream = builder.stream("prices")
		stream.mapValues[it * 2].mapValues[it / 2].foreach[key, value| println('''«key», «value»''')]
		stream.mapValues[it * 2].mapValues[it / 2].foreach[key, value|]
		
		val MStream<String, Integer> stream2 = builder.stream("random")
		stream2.mapValues[it * 2].mapValues[it / 2].foreach[key, value|]
		
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