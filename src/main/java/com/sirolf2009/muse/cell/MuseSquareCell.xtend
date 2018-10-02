package com.sirolf2009.muse.cell

import com.fxgraph.graph.Graph
import com.fxgraph.graph.ICell
import com.fxgraph.graph.Model
import com.sirolf2009.muse.Project
import javafx.collections.FXCollections
import javafx.collections.ListChangeListener
import javafx.collections.ListChangeListener.Change
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

@Accessors class MuseSquareCell extends MuseCell {
	
	val Model model

	new(Project project) {
		super(project)
		model = new Model()
	}

	new(Project project, MuseCell parent) {
		super(project, parent)
		model = new Model()
	}

	override getGraphic(Graph graph) {
		val view = new Rectangle(width.get(), height.get())

		view.setStroke(Color.BLACK)
		view.setFill(Color.WHITE)

		val subGraph = new Graph(model)
		subGraph.getCanvas().setStyle("-fx-background-color: rgb(12, 29.6, 32.7);")
		subGraph.getUseNodeGestures().set(false);
		subGraph.getUseViewportGestures().set(false);
		val scale = new Scale(1, 1, 0, 0)
		subGraph.getCanvas().widthProperty().addListener [ obs, oldVal, newVal |
			val myWidth = if(subGraph.getModel().getAllCells().size() > 0) {
					subGraph.getCanvas().getChildren().map[getLayoutX() + getBoundsInLocal().getWidth()].max()
				} else {
					subGraph.getCanvas().getWidth()
				}
			val availableWidth = view.getWidth() * 0.9
			val scaleX = availableWidth / myWidth
			scale.setX(scaleX)
			subGraph.getCanvas().setTranslateX(view.getWidth() * 0.05)
		]
		subGraph.getCanvas().heightProperty().addListener [ obs, oldVal, newVal |
			val myHeight = if(subGraph.getModel().getAllCells().size() > 0) {
					subGraph.getCanvas().getChildren().map[getLayoutY() + getBoundsInLocal().getHeight()].max()
				} else {
					subGraph.getCanvas().getHeight()
				}
			val availableHeight = view.getHeight() * 0.9
			val scaleY = availableHeight / myHeight
			scale.setY(scaleY)
			subGraph.getCanvas().setTranslateY(view.getHeight() * 0.05)
		]
		subGraph.getCanvas().getTransforms().add(scale)
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
			this.getWidth().unbind()
			setPrefWidth(this.getWidth().get())
			this.getWidth().bind(prefWidthProperty())
			this.getHeight().unbind()
			setPrefHeight(this.getHeight().get())
			this.getHeight().bind(prefHeightProperty())

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
	
	override getDepth() {
		if(model.getAllCells().filter[it instanceof MuseCell].isEmpty()) {
			return 0
		} else {
			model.getAllCells().filter[it instanceof MuseCell].map[it as MuseCell].map[getDepth()].max() + 1
		}
	}
	
	override getChildren() {
		val childNodes = FXCollections.observableArrayList(model.getAllCells().filter[it instanceof MuseCell].map[it as MuseCell].toList())
		model.getAllCells().addListener(new ListChangeListener<ICell>() {
			override onChanged(Change<? extends ICell> c) {
				while(c.next()) {
					c.getAddedSubList().filter[it instanceof MuseCell].map[it as MuseCell].forEach [
						childNodes.add(it)
					]
					c.getRemoved().filter[it instanceof MuseCell].map[it as MuseCell].forEach [
						childNodes.add(it)
					]
				}
			}
		})
		return childNodes
	}

}
