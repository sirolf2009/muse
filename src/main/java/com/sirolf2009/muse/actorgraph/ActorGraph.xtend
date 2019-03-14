package com.sirolf2009.muse.actorgraph

import com.fxgraph.graph.Graph
import com.fxgraph.layout.AbegoTreeLayout
import javafx.scene.control.Button
import javafx.scene.control.CheckBox
import javafx.scene.control.Slider
import javafx.scene.control.ToolBar
import javafx.scene.layout.HBox
import javafx.scene.layout.Priority
import javafx.scene.layout.VBox
import org.abego.treelayout.Configuration.Location
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class ActorGraph extends VBox {
	
	val ToolBar toolbar
	val Graph graph
	val Slider slider
	val CheckBox lock
	
	new() {
		graph = new Graph() => [
			getCanvas().getStyleClass().add("map-background")
		]
		toolbar = new ToolBar(new Button("layout") => [
			setOnAction [
				graph.layout(new AbegoTreeLayout(200, 200, Location.Bottom))	
			]
		])
		slider = new Slider()
		lock = new CheckBox()
		slider.disableProperty().bind(lock.selectedProperty().not())
		HBox.setHgrow(slider, Priority.ALWAYS)
		setVgrow(graph.getCanvas(), Priority.ALWAYS)
		getChildren().addAll(graph.getCanvas(), new HBox(slider, lock), toolbar)
	}
	
}
