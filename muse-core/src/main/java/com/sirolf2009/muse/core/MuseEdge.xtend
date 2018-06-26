package com.sirolf2009.muse.core

import com.fxgraph.edges.Edge
import com.fxgraph.graph.Graph
import javafx.animation.TranslateTransition
import javafx.scene.paint.Color
import javafx.scene.shape.Circle
import javafx.util.Duration
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor class MuseEdge extends Edge {

	override getGraphic(Graph graph) {
		super.getGraphic(graph) => [
			textProperty().addListener [ obs, oldVal, newVal |
				val line = getLine()
				val circle = new Circle(8, Color.VIOLET)
				graph.getCellLayer().getChildren().add(circle)
				new TranslateTransition(Duration.seconds(0.5d), circle) => [
					setFromX(line.getStartX())
					setFromY(line.getStartY())
					setToX(line.getEndX())
					setToY(line.getEndY())
					onFinished = [
						graph.getCellLayer().getChildren().remove(circle)
					]
					play()
				]
			]
		]
	}

}
