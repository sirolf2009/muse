package com.sirolf2009.muse.actorgraph

import akka.actor.ActorRef
import com.fxgraph.cells.AbstractCell
import com.fxgraph.graph.Graph
import javafx.beans.property.DoubleProperty
import javafx.beans.property.SimpleDoubleProperty
import javafx.geometry.Insets
import javafx.geometry.Pos
import javafx.scene.control.Label
import javafx.scene.layout.BorderPane
import javafx.scene.shape.Circle
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor @Accessors class ServerCell extends AbstractCell {

	val String name
	val ActorRef path
	@Deprecated
	val DoubleProperty loadProperty = new SimpleDoubleProperty()

	override getGraphic(Graph graph) {
		val pane = new BorderPane()
		pane.getStyleClass().add("graph-cell")
		pane.setPrefSize(50, 50)

		new Label(name) => [
			getStyleClass().add("white-text")
			BorderPane.setMargin(it, new Insets(10))
			BorderPane.setAlignment(it, Pos.CENTER)
			setMinSize(Label.USE_PREF_SIZE, Label.USE_PREF_SIZE)
			pane.setTop(it)
		]
		
		new Circle(16) => [
			getStyleClass().add("circle")
			pane.setCenter(it)
		]

		return pane
	}	
	
	override toString() {
		return '''ServerCell [«path»]'''
	}

}
