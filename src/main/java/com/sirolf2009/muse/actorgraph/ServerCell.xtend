package com.sirolf2009.muse.actorgraph

import akka.actor.ActorRef
import com.fxgraph.cells.AbstractCell
import com.fxgraph.graph.Graph
import javafx.geometry.Insets
import javafx.geometry.Pos
import javafx.scene.control.Label
import javafx.scene.layout.BorderPane
import javafx.scene.shape.Circle
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import akka.pattern.Patterns
import java.time.Duration
import javafx.scene.layout.StackPane
import javafx.application.Platform
import javafx.scene.input.MouseButton

@FinalFieldsConstructor @Accessors class ServerCell extends AbstractCell {

	val String name
	val ActorRef actor

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

		new StackPane() => [
			setMinSize(16, 16)
			getChildren().add(new Circle(16) => [
				getStyleClass().add("circle")
			])
			onMouseClicked = [ evt |
				try {
					if(evt.getButton() === MouseButton.SECONDARY) {
						Patterns.ask(actor, new InspectionRequest(), Duration.ofSeconds(1)).thenAcceptAsync [ msg |
							try {
								val response = msg as InspectionResponse
								val node = response.getInspection().get()
								node.setOnMouseExited [ evt2 |
									getChildren().remove(node)
								]
								Platform.runLater [
									getChildren().add(node)
								]
							} catch(Exception e) {
								e.printStackTrace()
							}
						]
					}
				} catch(Exception e) {
					e.printStackTrace()
				}
			]
			pane.setCenter(it)
		]

		return pane
	}

}
