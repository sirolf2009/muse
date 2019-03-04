package com.sirolf2009.muse

import com.fxgraph.cells.AbstractCell
import com.fxgraph.cells.CellGestures
import com.fxgraph.edges.Edge
import com.fxgraph.graph.Graph
import com.sirolf2009.muse.interfaces.DeleteMe.SimpleConsumer
import com.sirolf2009.muse.interfaces.DeleteMe.SimpleConverter
import com.sirolf2009.muse.interfaces.IDrawable
import java.io.File
import javafx.application.Application
import javafx.scene.Scene
import javafx.scene.layout.Pane
import javafx.scene.layout.Region
import javafx.scene.paint.Color
import javafx.scene.shape.Rectangle
import javafx.stage.Stage
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

class FXGraphTest extends Application {

	override start(Stage primaryStage) throws Exception {
		val groovySupplier = Component.compile('''
		import io.reactivex.Observable
		import io.reactivex.schedulers.Schedulers
		import java.util.concurrent.TimeUnit
		
		Component.create {
		 output "output1", {
		  data Observable.interval(1, TimeUnit.SECONDS).map{System.currentTimeMillis()}.subscribeOn(Schedulers.io())
		 }
		}''')
		val groovyConverter = Component.compile('''
		import java.util.Date
		
		Component.create {
		 input "input1"
		 output "output1"
		 
		 init {
		  input1().map{new Date(it)}.subscribe(output1())
		 }
		}''')

		val graph = new Graph()
		val model = graph.getModel()
		graph.beginUpdate()

//		val supplier = new SimpleSupplier()
		val supplier = groovySupplier
//		val converter = new SimpleConverter()
		val converter = groovyConverter
		val consumer = new SimpleConsumer()
		val supplierCell = new MuseCell(supplier)
		val converterCell = new MuseCell(converter)
		val consumerCell = new MuseCell(consumer)
		model.addCell(supplierCell)
		model.addCell(converterCell)
		model.addCell(consumerCell)

		supplier.getOutputs().get(0).getData().subscribe(converter.getInputs().get(0).getObserver())
		converter.getOutputs().get(0).getData().subscribe(consumer.getInputs().get(0).getObserver())

		val sc = new Edge(supplierCell, converterCell) => [ edge |
			supplier.getOutputs().get(0).getData().subscribe [
				edge.textProperty().set(toString())
			]
		]
		model.addEdge(sc)
		val cc = new Edge(converterCell, consumerCell) => [ edge |
			converter.getOutputs().get(0).getData().subscribe [
				edge.textProperty().set(toString())
			]
		]
		model.addEdge(cc)

		graph.endUpdate()

		primaryStage.setScene(new Scene(graph.getCanvas(), 800, 600))
		primaryStage.setOnCloseRequest[System.exit(0)]
		primaryStage.show()
	}

	def static void main(String[] args) {
		launch(args)
	}

	@FinalFieldsConstructor static class MuseCell extends AbstractCell {

		val IDrawable drawable

		override Region getGraphic(Graph graph) {
			val Rectangle view = new Rectangle(50, 50)
			view.setStroke(Color.DODGERBLUE)
			view.setFill(Color.DODGERBLUE)
			val Pane pane = new Pane(view)
			pane.setPrefSize(50, 50)
			view.widthProperty().bind(pane.prefWidthProperty())
			view.heightProperty().bind(pane.prefHeightProperty())
			CellGestures.makeResizable(pane)
			val editor = new GroovyEditor(new File(""))
			CellGestures.makeResizable(editor)
			return editor

		}
	}

}
