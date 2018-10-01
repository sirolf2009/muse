package com.sirolf2009.muse.cell

import com.fxgraph.graph.Graph
import com.fxgraph.graph.Model
import com.sirolf2009.muse.XtendEditor
import javafx.geometry.Pos
import javafx.scene.layout.StackPane
import javafx.scene.paint.Color
import javafx.scene.shape.Rectangle

class MuseCodeCell extends MuseCell {

	new(Model model) {
		super(model)
		getWidth().set(400)
	}

	new(MuseCell parent) {
		super(parent)
		getWidth().set(400)
	}

	override getGraphic(Graph graph) {
		val view = new Rectangle(width.get(), height.get())

		view.setStroke(Color.BLACK)
		view.setFill(Color.WHITE)

		val editor = new XtendEditor()
		editor.appendText(getName().get())
		editor.setTranslateY(10)
		editor.prefWidthProperty().bind(view.widthProperty())

		return new StackPane(view, editor) => [
			x.unbind()
			setLayoutX(x.get())
			x.bind(layoutXProperty())
			y.unbind()
			setLayoutY(y.get())
			y.bind(layoutYProperty())
			this.getWidth().unbind()
			setPrefWidth(this.getWidth().get())
			this.getWidth().bind(prefWidthProperty())
			this.getHeight().unbind()
			setPrefHeight(this.getHeight().get())
			this.getHeight().bind(prefHeightProperty().subtract(10))
			
			editor.prefWidthProperty().bind(widthProperty())
			editor.prefHeightProperty().bind(heightProperty())
			setAlignment(Pos.CENTER)
		]
	}

}
