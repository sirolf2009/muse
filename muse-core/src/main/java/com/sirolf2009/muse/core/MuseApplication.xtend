package com.sirolf2009.muse.core

import com.fxgraph.graph.Graph
import com.fxgraph.layout.AbegoTreeLayout
import com.fxgraph.layout.Layout
import com.sirolf2009.muse.core.model.Blueprint
import javafx.application.Application
import javafx.scene.Scene
import javafx.stage.Stage
import org.abego.treelayout.Configuration.Location
import javafx.geometry.Insets

abstract class MuseApplication extends Application {
	
	override start(Stage stage) throws Exception {
		val blueprint = getBlueprint()
		val graph = new Graph(blueprint.getModel())
		graph.endUpdate()
		graph.getCellLayer().getStyleClass().add("blueprint")
		val scene = new Scene(graph.getScrollPane(), 1200, 600)
		scene.getStylesheets().add(getClass().getResource("/application.css").toExternalForm())

		stage.setTitle(getTitle())
		stage.setScene(scene)
		stage.show()

		graph.layout(getLayout())
	}
	
	def Blueprint getBlueprint()
	
	def double getWidth() {
		return 1200
	}
	
	def double getHeight() {
		return 600
	}
	
	def String getTitle() {
		return "Muse Application"
	}
	
	def Layout getLayout() {
		new AbegoTreeLayout(200, 100, Location.Left)
	}
	
}