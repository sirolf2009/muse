package com.sirolf2009.muse.actorgraph

import com.fxgraph.edges.AbstractEdge
import com.fxgraph.graph.Graph
import javafx.beans.binding.DoubleBinding
import javafx.scene.layout.Pane
import javafx.scene.layout.Region
import javafx.scene.shape.Line
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor @Accessors class ServerEdge extends AbstractEdge {

	override getGraphic(Graph graph) {
		val pane = new Pane()
		val line = new Line()
		line.getStyleClass().add("graph-edge")
		val DoubleBinding sourceX = getSource().getXAnchor(graph, this)
		val DoubleBinding sourceY = getSource().getYAnchor(graph, this)
		val DoubleBinding targetX = getTarget().getXAnchor(graph, this)
		val DoubleBinding targetY = getTarget().getYAnchor(graph, this)
		line.startXProperty().bind(sourceX)
		line.startYProperty().bind(sourceY)
		line.endXProperty().bind(targetX)
		line.endYProperty().bind(targetY)
		pane.getChildren().add(line)
		pane.setMouseTransparent(true)
		return pane
	}
	
	override onAddedToGraph(Graph graph, Region region) {
		(region as Pane).toBack()
	}
	
	override toString() {
		return '''ServerEdge []'''
	}

}
