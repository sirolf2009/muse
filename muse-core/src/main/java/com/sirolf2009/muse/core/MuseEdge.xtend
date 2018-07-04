package com.sirolf2009.muse.core

import com.fxgraph.edges.AbstractEdge
import com.fxgraph.graph.Graph
import com.google.gson.Gson
import com.sirolf2009.muse.core.cells.MuseCell
import javafx.application.Platform
import javafx.scene.Group
import javafx.scene.control.Label
import javafx.scene.layout.Pane
import javafx.scene.shape.Line
import javafx.beans.property.SimpleDoubleProperty
import javafx.scene.text.Text

class MuseEdge<S, T> extends AbstractEdge {

	new(MuseCell<S> source, MuseCell<T> target) {
		super(source, target)
	}

	override getGraphic(Graph graph) {
		val pane = new Pane()
		val group = new Group()
		val line = new Line()

		val sourceNode = graph.getGraphic(getSource())
		val targetNode = graph.getGraphic(getTarget())

		line.startXProperty().bind(sourceNode.layoutXProperty().add(sourceNode.widthProperty().divide(2)))
		line.startYProperty().bind(sourceNode.layoutYProperty().add(sourceNode.heightProperty().divide(2)))

		line.endXProperty().bind(targetNode.layoutXProperty().add(targetNode.widthProperty().divide(2)))
		line.endYProperty().bind(targetNode.layoutYProperty().add(targetNode.heightProperty().divide(2)))
		group.getChildren().add(line)

		val centerX = line.startXProperty().add(line.endXProperty()).divide(2)
		val centerY = line.startYProperty().add(line.endYProperty()).divide(2)

		getSource().getLastOutput().subscribe [
			if(it instanceof IGraphic) {
				val node = it.getGraphic()
				val nodeWidth = new SimpleDoubleProperty()
				val nodeHeight = new SimpleDoubleProperty()
				val Runnable recalculateWidth = [
					nodeWidth.set(node.getLayoutBounds().getWidth())
					nodeHeight.set(node.getLayoutBounds().getHeight())
				]
				node.parentProperty().addListener[obs, oldVal, newVal|recalculateWidth.run()]
				node.layoutXProperty().bind(centerX.subtract(nodeWidth))
				node.layoutYProperty().bind(centerY.subtract(nodeHeight))
				Platform.runLater [
					pane.getChildren().clear()
					pane.getChildren().addAll(group, node)
				]
			} else {
				try {
					val textWidth = new SimpleDoubleProperty()
					val textHeight = new SimpleDoubleProperty()
					val text = new Text(new Gson().toJson(it))
					text.xProperty().bind(centerX.subtract(textWidth.divide(2)))
					text.yProperty().bind(centerY.subtract(textHeight.divide(2)))
					val Runnable recalculateWidth = [
						textWidth.set(text.getLayoutBounds().getWidth())
						textHeight.set(text.getLayoutBounds().getHeight())
					]
					text.parentProperty().addListener[obs, oldVal, newVal|recalculateWidth.run()]
					text.textProperty().addListener[obs, oldVal, newVal|recalculateWidth.run()]

					Platform.runLater [
						pane.getChildren().clear()
						pane.getChildren().addAll(group, text)
					]
				} catch(Exception e) {
					val label = new Label(toString())
					Platform.runLater [
						pane.getChildren().clear()
						pane.getChildren().addAll(group, label)
					]
				}
			}
		]
		pane
	}

	override MuseCell<S> getSource() {
		return super.getSource() as MuseCell<S>
	}

	override MuseCell<T> getTarget() {
		return super.getTarget() as MuseCell<T>
	}

}
