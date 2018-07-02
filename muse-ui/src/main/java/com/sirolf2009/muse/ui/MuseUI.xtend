package com.sirolf2009.muse.ui

import com.fxgraph.graph.Graph
import com.fxgraph.layout.AbegoTreeLayout
import com.sirolf2009.muse.ui.model.Connection
import com.sirolf2009.muse.ui.properties.LocalProperties
import javafx.application.Application
import javafx.application.Platform
import javafx.scene.Scene
import javafx.scene.layout.BorderPane
import javafx.scene.layout.VBox
import javafx.stage.Stage
import org.apache.kafka.common.serialization.Serdes

class MuseUI extends Application {

	def static void main(String[] args) throws Exception {
		launch(args)
	}

	override void start(Stage stage) throws Exception {
		val conn = new Connection(LocalProperties.withSerdes("MUSE-INTERNAL", Serdes.String(), Serdes.ByteArray()))
		val sceneRoot = new BorderPane()
		val graphs = new VBox()
		sceneRoot.setCenter(graphs)
		conn.getGraphModels().foreach("Add to UI") [ key, value |
			val graph = new Graph(value)
			Platform.runLater [
				graphs.getChildren().add(graph.getScrollPane())
				graph.layout(new AbegoTreeLayout())
			]
		]
		conn.start()

		val scene = new Scene(sceneRoot, 1200, 600)
		scene.getStylesheets().add(getClass().getResource("/application.css").toExternalForm())

		stage.setTitle("Hello JavaFX and Maven")
		stage.setOnCloseRequest[System.exit(0)]
		stage.setScene(scene)
		stage.show()
	}

}
