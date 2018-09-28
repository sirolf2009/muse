package com.sirolf2009.muse

import com.fxgraph.graph.Graph
import com.fxgraph.graph.ICell
import com.fxgraph.graph.IGraphNode
import com.fxgraph.graph.Model
import java.util.Random
import javafx.application.Application
import javafx.beans.binding.Bindings
import javafx.beans.property.SimpleObjectProperty
import javafx.collections.ListChangeListener
import javafx.scene.Scene
import javafx.scene.control.Slider
import javafx.scene.input.MouseEvent
import javafx.scene.layout.BorderPane
import javafx.stage.Stage

class Muse extends Application {

	val viewingModel = new SimpleObjectProperty<Model>()

	override start(Stage primaryStage) throws Exception {
		val borderPane = new BorderPane()
		val rootGraph = new Graph()

		rootGraph.beginUpdate()
		rootGraph.getModel().addCell(new MuseCell() => [
		])
		rootGraph.getModel().addCell(new MuseCell() => [
			y.set(1000)
		])
		rootGraph.getModel().addCell(new MuseCell() => [
			x.set(1000)
		])
		rootGraph.getModel().addCell(new MuseCell() => [
			x.set(1000)
			y.set(1000)
		])
		rootGraph.endUpdate()

		val slider = new Slider(0, 1, 0)
		slider.setBlockIncrement(1)
		slider.setMajorTickUnit(1)
		slider.setMinorTickCount(0)
		slider.setShowTickLabels(true)
		slider.setSnapToTicks(true)
		borderPane.setBottom(slider)
		rootGraph.getModel().getAllCells().addListener(new ListChangeListener<ICell>() {
			override onChanged(Change<? extends ICell> c) {
				val maxDepth = rootGraph.getModel().getAllCells().filter[it instanceof MuseCell].map[it as MuseCell].map[getDepth()].max()
				slider.setMax(maxDepth)
			}
		})
		val sliderValue = Bindings.createIntegerBinding([
			Math.floor(slider.getValue()) as int
		], slider.valueProperty())

		viewingModel.addListener [ obs, oldVal, newVal |
			if(newVal !== null) {
				val graph = new Graph(newVal) {
					override createGraphic(IGraphNode node) {
						val graphic = super.createGraphic(node)
						if(node instanceof MuseCell) {
							graphic.addEventFilter(MouseEvent.MOUSE_CLICKED) [
								if(getClickCount() == 1 && isControlDown()) {
									viewingModel.set(node.getModel())
									consume()
								}
							]
						}
						return graphic
					}
				}
				graph.getCanvas().addEventHandler(MouseEvent.MOUSE_CLICKED) [
					if(getClickCount() == 2) {
						newVal.addCell(new MuseCell() => [ cell |
							cell.getX().set(getX() - (cell.getWidth().get()/2))
							cell.getY().set(getY() - (cell.getHeight().get()/2))
							cell.getShowContents().bind(sliderValue.greaterThan(cell.getLevel()))
							cell.getModel().addCell(new MuseCell() => [ child |
								if(new Random().nextInt(5) == 0) {
									child.getModel().addCell(new MuseCell(cell))
									child.getModel().endUpdate()
								}
							])
							cell.getModel().endUpdate()
							consume()
						])
						graph.endUpdate()
						consume()
					}
				]
				borderPane.setCenter(graph.getCanvas())
			}
		]

		viewingModel.set(rootGraph.getModel())
		

		val scene = new Scene(borderPane, 1024, 768)
		scene.getStylesheets().add(getClass().getResource("/application.css").toExternalForm())
		
		primaryStage.setScene(scene)
		primaryStage.show()

//		val injector = XtendInjectorSingleton.INJECTOR
//		XtendBatchCompiler xtendBatchCompiler = injector.getInstance(XtendBatchCompiler.class);
//		if ((args == null) || (args.length == 0)) {
//			printUsage();
//			return;
//		}
//		Iterator<String> arguments = Arrays.asList(args).iterator();
//		while (arguments.hasNext()) {
//			String argument = arguments.next();
//			if ("-d".equals(argument.trim())) {
//				xtendBatchCompiler.setOutputPath(arguments.next().trim());
//			} else if ("-classpath".equals(argument.trim()) || "-cp".equals(argument.trim())) {
//				xtendBatchCompiler.setClassPath(arguments.next().trim());
//			} else if ("-tempdir".equals(argument.trim()) || "-td".equals(argument.trim())) {
//				xtendBatchCompiler.setTempDirectory(arguments.next().trim());
//			} else if ("-encoding".equals(argument.trim())) {
//				xtendBatchCompiler.setFileEncoding(arguments.next().trim());
//			} else if ("-useCurrentClassLoader".equals(argument.trim())) {
//				xtendBatchCompiler.setUseCurrentClassLoaderAsParent(true);
//			} else {
//				xtendBatchCompiler.setSourcePath(argument);
//			}
//		}
//		if (!xtendBatchCompiler.compile()) {
//			System.exit(1);
//		}
	}

	def static void main(String[] args) {
		launch(args)
	}

	def static layout(ICell cell, Graph graph, double x, double y) {
		graph.getGraphic(cell) => [
			parentProperty().addListener [ obs, oldVal, newVal |
				setLayoutX(x)
				setLayoutY(y)
				println('''«getLayoutX()», «getLayoutY()»''')
			]
		]
	}

}
