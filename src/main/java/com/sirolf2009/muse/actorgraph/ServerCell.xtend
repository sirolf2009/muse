package com.sirolf2009.muse.actorgraph

import akka.actor.ActorRef
import akka.pattern.Patterns
import com.fxgraph.cells.AbstractCell
import com.fxgraph.graph.Graph
import com.sirolf2009.muse.event.EventLog
import com.sirolf2009.util.TimeUtil
import java.time.Duration
import javafx.application.Platform
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.geometry.Insets
import javafx.geometry.Pos
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.control.ToggleButton
import javafx.scene.control.ToolBar
import javafx.scene.control.Tooltip
import javafx.scene.image.ImageView
import javafx.scene.input.MouseButton
import javafx.scene.layout.BorderPane
import javafx.scene.layout.HBox
import javafx.scene.layout.Pane
import javafx.scene.layout.Priority
import javafx.scene.layout.StackPane
import javafx.scene.layout.VBox
import javafx.scene.shape.Circle
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor @Accessors class ServerCell extends AbstractCell {

	val String name
	val ActorRef actor
	val ObservableList<EventLog> logging = FXCollections.observableArrayList()

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
					if(evt.getButton() === MouseButton.PRIMARY && evt.isControlDown()) {
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
					} else if(evt.getButton() === MouseButton.PRIMARY && evt.isAltDown()) {
						val logs = new TableView(logging)
						logs.getColumns().add(new TableColumn<EventLog, String>("Timestamp") => [
							setCellValueFactory [
								new SimpleStringProperty(TimeUtil.format(getValue().getTimestamp()))
							]
						])
						logs.getColumns().add(new TableColumn<EventLog, String>("Level") => [
							setCellValueFactory [
								new SimpleStringProperty(getValue().getLogLevel().asWord())
							]
						])
						logs.getColumns().add(new TableColumn<EventLog, String>("Thread") => [
							setCellValueFactory [
								new SimpleStringProperty(getValue().getThread())
							]
						])
						logs.getColumns().add(new TableColumn<EventLog, String>("Message") => [
							setCellValueFactory [
								new SimpleStringProperty(getValue().getMsg())
							]
						])
						logs.setMinSize(600, 200)
						val spacer = new Pane() => [
							HBox.setHgrow(it, Priority.ALWAYS)
						]
						val pin = new ToggleButton() => [
							setTooltip(new Tooltip("Pin the console"))
							setGraphic(new ImageView("push-pin.png") => [
								setFitWidth(16)
								setFitHeight(16)
							])
						]
						val clear = new Button() => [
							setTooltip(new Tooltip("Clear the console"))
							setGraphic(new ImageView("eraser.png") => [
								setFitWidth(16)
								setFitHeight(16)
							])
							setOnAction [
								logging.clear()
							]
						]
						val logControls = new ToolBar(spacer, clear, pin)
						val logContainer = new VBox(logControls, logs)
						VBox.setVgrow(logs, Priority.ALWAYS)

						pin.selectedProperty().addListener [ obs, oldVal, newVal |
							if(newVal) {
								logContainer.setOnMouseExited[]
							} else {
								logContainer.setOnMouseExited [ evt2 |
									getChildren().remove(logContainer)
								]
							}
						]
						logContainer.setOnMouseExited [ evt2 |
							getChildren().remove(logContainer)
						]
						Platform.runLater [
							getChildren().add(logContainer)
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

	def asWord(int level) {
		switch (level) {
			case 1: "ERROR"
			case 2: "WARN"
			case 3: "INFO"
			default: "UNKNOWN"
		}
	}

}
