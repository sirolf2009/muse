package com.sirolf2009.muse.rxjava2

import com.fxgraph.graph.Graph
import com.fxgraph.layout.AbegoTreeLayout
import com.sirolf2009.muse.core.IGraphic
import io.reactivex.Observable
import javafx.application.Application
import javafx.scene.Scene
import javafx.scene.control.Label
import javafx.scene.control.TitledPane
import javafx.scene.layout.VBox
import javafx.stage.Stage
import org.abego.treelayout.Configuration.Location
import org.eclipse.xtend.lib.annotations.Data

class RXJava2Driver extends Application {

	def static void main(String[] args) {
		launch(args)
	}

	override start(Stage primaryStage) throws Exception {
		Observable.fromArray("simpleCalculation" -> simpleCalculation(), "visualCalculation" -> visualCalculation(), "complicatedCalculation" -> complicatedCalculation()).map [
			val graph = new Graph(value.getModel())
			graph.endUpdate()
			graph.layout(new AbegoTreeLayout(400, 400, Location.Left))
			new TitledPane(key, graph.getCanvas())
		].toList().map [
			new Scene(new VBox(it), 1200, 600)
		].subscribe [
			primaryStage.setOnCloseRequest[System.exit(0)]
			primaryStage.setScene(it)
			primaryStage.show()
		]
	}

	def simpleCalculation() {
		new ObservableSource(Observable.range(0, 100), "0 to 100").map("0 to 200") [
			it * 2
		].map("0 to 400") [
			it * 2
		].forEach("print to screen") [
//			println(it)
		]
	}

	def visualCalculation() {
		new ObservableSource(Observable.range(0, 100), "0 to 100").map("as NumberObject")[new NumberObject(it)].map("0 to 200") [
			new NumberObject(getNumber() * 2)
		].map("0 to 400") [
			new NumberObject(getNumber() * 2)
		].forEach("print to screen") [
//			println(it)
		]
	}

	def complicatedCalculation() {
		println("complicated calculation")
		new ObservableSource(Observable.just(1), "1").map("as NumberObject")[
			println("calling map on "+it)
			new NumberObject(it)
		].flatMap("Some random complicated shit") [value|
			println("calling flatmap on "+value)
			new ObservableSource(Observable.fromArray(1, 2, 3), "[1,2,3]").map("it * value") [new NumberObject(it * value.getNumber())]
		].map("0 to 400") [
			new NumberObject(getNumber() * 2)
		].forEach("print to screen") [
//			println(it)
		]
	}

	@Data static class NumberObject implements IGraphic {

		val double number

		override getGraphic() {
			return new Label(String.valueOf(number)) => [
				setStyle('''-fx-background-color: red;''')
			]
		}

	}
	
}
