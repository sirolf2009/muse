package com.sirolf2009.muse.messagetable

import javafx.scene.control.Button
import javafx.scene.control.ToolBar
import javafx.scene.layout.Priority
import javafx.scene.layout.VBox
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class Messages extends VBox {
	
	val MessageTable messageTable
	val Button showSequenceDiagram
	
	new() {
		messageTable = new MessageTable() => [
			VBox.setVgrow(it, Priority.ALWAYS)
		]
		showSequenceDiagram = new Button("Sequence Diagram") => [
//			getStyleClass().add("show-seq-diagram-btn")
//			setGraphic(new ImageView("sequenceDiagram.png") => [
//				setWidth(12)
//			])
		]
		getChildren().addAll(new ToolBar(showSequenceDiagram), messageTable)
	}
	
}