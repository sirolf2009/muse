package com.sirolf2009.muse.ui.controller

import com.fxgraph.graph.Graph
import com.sirolf2009.muse.core.MStreamBuilder
import com.sirolf2009.muse.ui.properties.LocalProperties
import java.util.ArrayList
import java.util.List
import javafx.fxml.FXML
import javafx.scene.Node
import javafx.scene.control.ToggleButton
import javafx.scene.layout.AnchorPane
import javafx.scene.layout.FlowPane
import javafx.scene.layout.StackPane
import org.apache.kafka.common.serialization.Serdes
import com.fxgraph.layout.AbegoTreeLayout
import org.abego.treelayout.Configuration.Location
import javafx.beans.property.SimpleObjectProperty
import com.sirolf2009.muse.core.MKafkaStream

class ConnectionController extends AnchorPane {
	
	@FXML var StackPane canvasContainer
	@FXML var FlowPane commandPane
	@FXML var AnchorPane commandDetailPane
	
	val List<ToggleButton> commands = new ArrayList()
	val SimpleObjectProperty<Graph> graphProperty = new SimpleObjectProperty()
	
	
	new() {
		ControllerUtil.load(this, "/fxml/Connection.fxml")
	}
	
	@FXML
	def void initialize() {
		val props = LocalProperties.withSerdes("example-application", Serdes.Long(), Serdes.Double())
		val builder = new MStreamBuilder(props)

		val MKafkaStream<Long, Double> stream = builder.stream("prices")
		stream.mapValues[it * 2].mapValues[it / 2].foreach[key, value| println('''«key», «value»''')]
		stream.mapValues[it * 2].mapValues[it / 2].foreach[key, value|]
		
		val MKafkaStream<String, Integer> stream2 = builder.stream("random")
		stream2.mapValues[it * 2].mapValues[it / 2].foreach[key, value|]
		
		val streams = builder.build()
		streams.cleanUpAndStart()
    	val graph = new Graph(streams.getModel())
    	graph.endUpdate()
    	canvasContainer.getChildren().add(graph.getCellLayer())
    	graphProperty.set(graph)
    	layoutGraph()
	}
	
	def layoutGraph() {
		graphProperty.get().layout(new AbegoTreeLayout(100, 45, Location.Left))
	}
	
	def setDetail(Node node) {
		commandDetailPane.getChildren().clear()
		commandDetailPane.getChildren().add(node)
		AnchorPane.setTopAnchor(node, 0d)
		AnchorPane.setRightAnchor(node, 0d)
		AnchorPane.setBottomAnchor(node, 0d)
		AnchorPane.setLeftAnchor(node, 0d)
	}
	
}