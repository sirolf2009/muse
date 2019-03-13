package com.sirolf2009.muse.akka

import com.fxgraph.graph.Graph
import javafx.scene.control.CheckBox
import javafx.scene.control.Slider
import javafx.scene.layout.Priority
import javafx.scene.layout.VBox
import org.eclipse.xtend.lib.annotations.Accessors
import javafx.scene.layout.HBox

@Accessors class ActorGraph extends VBox {
	
	val Graph graph
	val Slider slider
	val CheckBox lock
	
	new() {
		graph = new Graph() => [
			getCanvas().getStyleClass().add("map-background")
		]
		slider = new Slider()
		lock = new CheckBox()
		slider.disableProperty().bind(lock.selectedProperty().not())
		HBox.setHgrow(slider, Priority.ALWAYS)
		setVgrow(graph.getCanvas(), Priority.ALWAYS)
		getChildren().addAll(graph.getCanvas(), new HBox(slider, lock))
	}
	
}