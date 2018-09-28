package com.sirolf2009.muse

import com.fxgraph.cells.AbstractCell
import com.fxgraph.graph.Graph
import com.fxgraph.graph.Model
import javafx.beans.property.SimpleBooleanProperty
import javafx.beans.property.SimpleDoubleProperty
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.geometry.Pos
import javafx.scene.control.Label
import javafx.scene.control.TextField
import javafx.scene.input.KeyCode
import javafx.scene.input.KeyEvent
import javafx.scene.input.MouseEvent
import javafx.scene.layout.StackPane
import javafx.scene.paint.Color
import javafx.scene.shape.Rectangle
import javafx.scene.transform.Scale
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class MuseCell extends AbstractCell {

	val Model model = new Model()
	val name = new SimpleStringProperty("new cell")
	val showContents = new SimpleBooleanProperty()
	val parent = new SimpleObjectProperty<MuseCell>()
	val x = new SimpleDoubleProperty(0)
	val y = new SimpleDoubleProperty(0)
	val width = new SimpleDoubleProperty(200)
	val height = new SimpleDoubleProperty(200)

	new() {
	}

	new(MuseCell parent) {
		this.parent.set(parent)
	}

	override getGraphic(Graph graph) {
		val view = new Rectangle(width.get(), height.get())

		view.setStroke(Color.BLACK)
		view.setFill(Color.WHITE)

		val subGraph = new Graph(model)
		val scale = new Scale(1, 1, 0, 0)
		subGraph.getCanvas().setStyle("-fx-background-color: rgba(255, 0, 0, 0.5);")
		subGraph.getCanvas().widthProperty().addListener [ obs, oldVal, newVal |
			val myWidth = subGraph.getCanvas().getWidth()
			val availableWidth = view.getWidth()
			val scaleX = myWidth / availableWidth
			scale.setX(scaleX)
			println('''My Width: «myWidth»''')
			println('''Available Width: «availableWidth»''')
			println('''ScaleX: «scaleX»''')
			println('''canvas X: «subGraph.getCanvas().getLayoutX()»''')
			println()
		]
		subGraph.getCanvas().heightProperty().addListener [ obs, oldVal, newVal |
			val availableHeight = view.getHeight()
			scale.setY(availableHeight / newVal.doubleValue())
		]
		subGraph.getCanvas().getTransforms().add(scale)
		subGraph.getCanvas().setTranslateX(50)
		subGraph.getCanvas().setTranslateY(50)
		subGraph.getCanvas().visibleProperty().bind(showContents)

		val label = new Label()
		label.textProperty().bind(name)
		label.visibleProperty().bind(showContents.not())
		val labelContainer = new StackPane(label)

		return new StackPane(view, labelContainer, subGraph.getCanvas()) => [
			x.unbind()
			setLayoutX(x.get())
			x.bind(layoutXProperty())
			y.unbind()
			setLayoutY(y.get())
			y.bind(layoutYProperty())
			width.unbind()
			setPrefWidth(width.get())
			width.bind(prefWidthProperty())
			height.unbind()
			setPrefHeight(height.get())
			height.bind(prefHeightProperty())

			setAlignment(Pos.CENTER)
			addEventFilter(MouseEvent.MOUSE_CLICKED) [
				consume()
				if(getClickCount() == 2) {
					labelContainer.getChildren().remove(label)

					val textField = new TextField(label.getText())
					textField.prefWidthProperty().bind(view.widthProperty())
					labelContainer.getChildren().add(textField)

					val Runnable swapTextField = [
						labelContainer.getChildren().remove(textField)
						name.set(textField.getText())
						labelContainer.getChildren().add(label)
					]
					textField.addEventFilter(MouseEvent.MOUSE_CLICKED) [
						if(getClickCount() == 2) {
							swapTextField.run()
							consume()
						}
					]
					textField.addEventFilter(KeyEvent.KEY_RELEASED) [
						if(getCode() == KeyCode.ENTER) {
							consume()
							swapTextField.run()
						}
					]
				}
			]
		]
	}

	def int getDepth() {
		if(model.getAllCells().filter[it instanceof MuseCell].isEmpty()) {
			return 0
		} else {
			model.getAllCells().filter[it instanceof MuseCell].map[it as MuseCell].map[getDepth()].max() + 1
		}
	}

	def int getLevel() {
		if(parent.get() === null) {
			return 0
		} else {
			return parent.get().getLevel() + 1
		}
	}

}
