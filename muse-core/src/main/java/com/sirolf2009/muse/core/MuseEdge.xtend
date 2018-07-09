package com.sirolf2009.muse.core

import com.fxgraph.edges.AbstractEdge
import com.fxgraph.graph.Graph
import com.google.gson.Gson
import com.sirolf2009.muse.core.cells.MuseCell
import javafx.application.Platform
import javafx.scene.Group
import javafx.scene.layout.Pane
import javafx.scene.paint.Color
import javafx.scene.shape.Line
import org.fxmisc.richtext.CodeArea
import org.fxmisc.richtext.LineNumberFactory
import io.reactivex.Observable

class MuseEdge<S, T> extends AbstractEdge {

	new(MuseCell<S> source, MuseCell<T> target) {
		super(source, target)
	}

	override getGraphic(Graph graph) {
		val pane = new Pane()
		val group = new Group()
		val line = new Line()
		line.setStrokeWidth(16)
		line.setStroke(Color.BLANCHEDALMOND)

		val sourceNode = graph.getGraphic(getSource())
		val targetNode = graph.getGraphic(getTarget())

		line.startXProperty().bind(sourceNode.layoutXProperty().add(sourceNode.widthProperty().divide(2)))
		line.startYProperty().bind(sourceNode.layoutYProperty().add(sourceNode.heightProperty().divide(2)))

		line.endXProperty().bind(targetNode.layoutXProperty().add(targetNode.widthProperty().divide(2)))
		line.endYProperty().bind(targetNode.layoutYProperty().add(targetNode.heightProperty().divide(2)))
		group.getChildren().add(line)
		pane.getChildren().add(group)

		val centerX = line.startXProperty().add(line.endXProperty()).divide(2)
		val centerY = line.startYProperty().add(line.endYProperty()).divide(2)

		getSource().getLastOutput().flatMap [
			if(it instanceof IGraphic) {
				return Observable.just(getGraphic())
			} else {
				Observable.just(it).map [
					try {
						new Gson().toJson(it)
					} catch(Exception e) {
						e.printStackTrace
						String.valueOf(it)
					}
				].map [
					val codeArea = new CodeArea()
					codeArea.setParagraphGraphicFactory(LineNumberFactory.get(codeArea))
					codeArea.replaceText(0, 0, it)
					codeArea.prefHeight = 16
					codeArea
				]
			}
		].subscribe [
			Platform.runLater [
				pane.getChildren().clear()
				pane.getChildren().addAll(group, it)
				layoutXProperty().bind(centerX.subtract(getLayoutBounds().getWidth() / 2))
				layoutYProperty().bind(centerY.subtract(getLayoutBounds().getHeight() / 2))
			]
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
