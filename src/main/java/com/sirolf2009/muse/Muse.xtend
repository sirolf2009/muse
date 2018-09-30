package com.sirolf2009.muse

import com.fxgraph.graph.Graph
import com.fxgraph.graph.ICell
import com.fxgraph.graph.IGraphNode
import com.fxgraph.graph.Model
import com.sirolf2009.muse.focusstack.FocusStack
import com.sirolf2009.muse.focusstack.FocusStackViewer
import com.sirolf2009.treeviewhierarchy.TreeViewHierarchy
import javafx.application.Application
import javafx.beans.binding.Bindings
import javafx.collections.FXCollections
import javafx.collections.ListChangeListener.Change
import javafx.scene.Scene
import javafx.scene.control.Slider
import javafx.scene.control.TreeItem
import javafx.scene.input.KeyCode
import javafx.scene.input.KeyEvent
import javafx.scene.input.MouseEvent
import javafx.scene.layout.BorderPane
import javafx.scene.layout.Pane
import javafx.scene.layout.StackPane
import javafx.scene.layout.VBox
import javafx.stage.Stage

class Muse extends Application {

	val focusStack = new FocusStack()

	override start(Stage primaryStage) throws Exception {
		val overlay = new BorderPane()
		overlay.setPickOnBounds(false)

		val centerSpace = new Pane()
		centerSpace.setVisible(false)
		centerSpace.setPickOnBounds(false)
		overlay.setCenter(centerSpace)

		val stackPane = new StackPane(overlay)
		val rootModel = new Model()
		val rootCell = new MuseCell(rootModel)
		rootCell.getName().set("Root Node")

		val explorer = new TreeViewHierarchy(new TreeItem(rootCell))
		explorer.setItems(FXCollections.observableArrayList(rootCell))
		explorer.setShowRoot(false)

		val focusStackViewer = new FocusStackViewer(focusStack)

		overlay.setRight(new VBox(explorer, focusStackViewer) => [
			setStyle("-fx-background-color: white;")
		])

		val focusSlider = new Slider(0, 0, 0)
		focusSlider.setBlockIncrement(1)
		focusSlider.setMajorTickUnit(1)
		focusSlider.setMinorTickCount(0)
		focusSlider.setShowTickLabels(true)
		focusSlider.setSnapToTicks(true)
		val focusValue = Bindings.createIntegerBinding([
			Math.floor(focusSlider.getValue()) as int
		], focusSlider.valueProperty())
		focusValue.addListener [ obs, oldVal, newVal |
			focusStack.getFocusIndex().set(focusValue.get())
		]
		focusStack.getFocusList().addListener[Change<? extends MuseCell> c|
			focusSlider.setMax(Math.max(0, focusStack.getFocusList().size()-1))
		]
		focusStack.getFocusIndex().addListener [ obs, oldVal, newVal |
			focusSlider.setValue(focusStack.getFocusIndex().get())
		]

		val visibilitySlider = new Slider(0, 0, 0)
		visibilitySlider.setBlockIncrement(1)
		visibilitySlider.setMajorTickUnit(1)
		visibilitySlider.setMinorTickCount(0)
		visibilitySlider.setShowTickLabels(true)
		visibilitySlider.setSnapToTicks(true)
		val visibilityValue = Bindings.createIntegerBinding([
			Math.floor(visibilitySlider.getValue()) as int
		], visibilitySlider.valueProperty())

		overlay.setBottom(new VBox(focusSlider, visibilitySlider) => [
			setStyle("-fx-background-color: white;")
		])

		rootCell.getShowContents().bind(focusValue.greaterThanOrEqualTo(rootCell.getLevel()))

		focusStack.getFocusedCell().addListener [ obs, oldVal, newVal |
			if(newVal !== null) {
				focusSlider.setValue(newVal.getLevel())
				val model = newVal.getModel()
				val graph = new Graph(model) {
					override createGraphic(IGraphNode node) {
						val graphic = super.createGraphic(node)
						if(node instanceof MuseCell) {
							graphic.addEventFilter(MouseEvent.MOUSE_CLICKED) [
								if(getClickCount() == 1 && isControlDown()) {
									focusStack.push(node)
									consume()
								}
							]
						}
						return graphic
					}
				}
				model.getAddedCells().addListener [ Change<? extends ICell> evt |
					graph.endUpdate()
				]
				graph.getCanvas().setStyle("-fx-background-color: rgb(2, 19.6, 22.7);")
				graph.getCanvas().setTranslateX(-100)
				if(stackPane.getChildren().size() == 2) {
					stackPane.getChildren().remove(0)
				}
				graph.getCanvas().maxHeightProperty().bind(centerSpace.heightProperty())
				stackPane.getChildren().set(0, graph.getCanvas())
				stackPane.getChildren().add(overlay)
			}
		]
		focusStack.push(rootCell)

		val scene = new Scene(stackPane, 1024, 768)
		scene.getStylesheets().add(getClass().getResource("/application.css").toExternalForm())
		scene.addEventHandler(KeyEvent.KEY_RELEASED) [
			if(getCode().equals(KeyCode.LEFT) && isAltDown()) {
				focusStack.descend()
				consume()
			}
			if(getCode().equals(KeyCode.RIGHT) && isAltDown()) {
				focusStack.ascend()
				consume()
			}
		]
		scene.addEventHandler(MouseEvent.MOUSE_CLICKED) [
			if(getClickCount() == 2) {
				focusStack.getFocusedCell().get().getModel().addCell(new MuseCell(focusStack.getFocusedCell().get()) => [ cell |
					cell.getX().set(getX() - (cell.getWidth().get() / 2))
					cell.getY().set(getY() - (cell.getHeight().get() / 2))
					cell.getShowContents().bind(visibilityValue.greaterThanOrEqualTo(cell.getLevel()))
					cell.getModel().endUpdate()
					cell.getName().set('''New cell @ «cell.getLevel()»''')
					cell.getName().addListener[evt|explorer.update()]
					consume()
				])
				visibilitySlider.setMax(rootCell.getDepth())
				consume()
			}
		]

		primaryStage.setScene(scene)
		primaryStage.show()
	}

	def static void main(String[] args) {
		launch(args)
	}

}
