package com.sirolf2009.muse.core

import com.fxgraph.graph.Cell
import javafx.scene.control.Label
import javafx.beans.property.StringProperty
import javafx.scene.layout.AnchorPane
import javafx.scene.text.TextAlignment
import javafx.geometry.Pos

class TextCell extends Cell {
	
	val StringProperty textProperty
	
	new(String text) {
		val label = new Label(text) => [
			textAlignment = TextAlignment.CENTER
			alignment = Pos.CENTER
		]
		setView(new AnchorPane(label) => [
			AnchorPane.setBottomAnchor(label, 0d)
			AnchorPane.setTopAnchor(label, 0d)
			AnchorPane.setLeftAnchor(label, 0d)
			AnchorPane.setRightAnchor(label, 0d)
		])
		textProperty = label.textProperty()
	}
	
	override toString() {
		return "Cell: "+textProperty.get()
	}
	
}