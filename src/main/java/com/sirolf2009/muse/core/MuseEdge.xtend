package com.sirolf2009.muse.core

import com.fxgraph.graph.Cell
import com.fxgraph.graph.CellLayer
import com.fxgraph.graph.Edge
import com.fxgraph.graph.Graph
import javafx.animation.TranslateTransition
import javafx.scene.paint.Color
import javafx.scene.shape.Circle
import javafx.util.Duration

class MuseEdge extends Edge {

	new(Graph graph, Cell source, Cell target) {
		super(source, target)
		textProperty().addListener [
			val circle = new Circle(8, Color.VIOLET)
			(getLine().getParent().getParent() as CellLayer).getChildren().add(circle)
			new TranslateTransition(Duration.seconds(0.5d), circle) => [
				setFromX(getLine().getStartX())
				setFromY(getLine().getStartY())
				setToX(getLine().getEndX())
				setToY(getLine().getEndY())
				onFinished = [
					(getLine().getParent().getParent() as CellLayer).getChildren().remove(circle)
				]
				play()
			]
		]
	}

}
