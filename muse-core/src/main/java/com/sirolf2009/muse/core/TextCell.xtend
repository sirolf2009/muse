package com.sirolf2009.muse.core

import com.fxgraph.cells.AbstractCell
import com.fxgraph.graph.Graph
import javafx.beans.property.SimpleStringProperty
import javafx.beans.property.StringProperty
import javafx.geometry.Pos
import javafx.scene.control.Label
import javafx.scene.layout.AnchorPane
import javafx.scene.text.TextAlignment

class TextCell extends AbstractCell {
	
	val StringProperty textProperty
	
	new(String text) {
		textProperty = new SimpleStringProperty(text)
	}
	
	override getGraphic(Graph graph) {
		val label = new Label() => [
			textProperty().bind(textProperty)
			textAlignment = TextAlignment.CENTER
			alignment = Pos.CENTER
		]
		return new AnchorPane(label) => [
			AnchorPane.setBottomAnchor(label, 0d)
			AnchorPane.setTopAnchor(label, 0d)
			AnchorPane.setLeftAnchor(label, 0d)
			AnchorPane.setRightAnchor(label, 0d)
		]
	}
	
	override toString() {
		return "Cell: "+textProperty.get()
	}
	
}