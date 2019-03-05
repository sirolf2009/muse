package com.sirolf2009.muse.akka

import akka.actor.AbstractActor
import akka.actor.ActorRef
import akka.actor.ActorSystem
import akka.actor.Props
import akka.event.Logging
import com.fxgraph.cells.AbstractCell
import com.fxgraph.graph.Graph
import com.fxgraph.layout.AbegoTreeLayout
import com.typesafe.config.ConfigFactory
import java.util.HashMap
import java.util.Map
import java.util.Random
import javafx.animation.PathTransition
import javafx.application.Application
import javafx.application.Platform
import javafx.beans.property.DoubleProperty
import javafx.beans.property.SimpleDoubleProperty
import javafx.geometry.Insets
import javafx.scene.Node
import javafx.scene.Scene
import javafx.scene.control.Label
import javafx.scene.control.ListView
import javafx.scene.control.ProgressBar
import javafx.scene.layout.BorderPane
import javafx.scene.layout.StackPane
import javafx.scene.paint.Color
import javafx.scene.shape.Circle
import javafx.scene.shape.LineTo
import javafx.scene.shape.MoveTo
import javafx.scene.shape.Path
import javafx.scene.text.Text
import javafx.stage.Stage
import javafx.util.Duration
import org.abego.treelayout.Configuration.Location
import org.apache.commons.math3.stat.descriptive.SummaryStatistics
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import javafx.geometry.Pos

class AkkaFXGraphServer extends Application {

	override start(Stage primaryStage) throws Exception {
		val root = new BorderPane() => [
			setStyle("-fx-background-color: rgb(5, 50, 58);")
		]

		val graph = new Graph() => [
			getCanvas().setStyle("-fx-background-color: rgb(5, 50, 58);")
		]
		val receivedList = new ListView<EventMessage>()

		root.setCenter(graph.getCanvas())
		root.setRight(receivedList)

		val scene = new Scene(root, 1024, 768)
		val system = ActorSystem.create("muse-server-system", ConfigFactory.load("application.conf"))
		val actor = system.actorOf(Props.create(ServerActor, graph, receivedList), "ServerActor")
		system.eventStream().subscribe(actor, Event)

		val dummy = system.actorOf(Props.create(DummyActor), "DummyActor")
		val dummy2 = system.actorOf(Props.create(DummyActor), "DummyActor2")
		primaryStage.setScene(scene)
		primaryStage.show()

		new Thread [
			while(true) {
				Thread.sleep(1000)
				if(new Random().nextInt(2) == 1) {
					dummy.tell("Hello!", dummy2)
					dummy.tell("Hello!", dummy2)
				} else {
					dummy.tell(new IGraphic() {

						override getNode() {
							return new Label("Hello!") => [
								setStyle('''-fx-background-color: green; -fx-padding: 8px;''')
							]
						}
						
						override toString() {
							return "Hello! label"
						}

					}, dummy2)
				}
			}
		].start()
	}

	def static void main(String[] args) {
		launch(args)
	}

	@FinalFieldsConstructor static class ServerActor extends AbstractActor {

		val Graph graph
		val ListView<EventMessage> listView
		var ActorRef graphActor
		var ActorRef listActor

		override preStart() throws Exception {
			graphActor = context().actorOf(Props.create(GraphActor, graph), "Graph")
			listActor = context().actorOf(Props.create(ReceivedListActor, listView), "List")
		}

		override createReceive() {
			return receiveBuilder().match(EventSpawn) [
				graphActor.tell(it, self())
			].match(EventMessage) [
				graphActor.tell(it, self())
				listActor.tell(it, self())
			].build()
		}

	}

	@FinalFieldsConstructor static class GraphActor extends AbstractActor {

		val Graph graph
		val Map<String, ServerCell> cells = new HashMap()
		val Map<String, ActorRef> cellManagers = new HashMap()

		override createReceive() {
			return receiveBuilder().match(EventSpawn) [
				if(getActor().isDefined() && !cellManagers.values().contains(getActor().get())) {
					Platform.runLater [
						val actor = getActor().get()
						(0 ..< actor.path().elements().size()).forEach [
							val name = actor.path().getElements().last()
							val path = actor.path().getElements().take(it + 1).join("/")
							println(path)
							if(!cells.containsKey(path)) {
								val cell = new ServerCell(name)
								graph.getModel().addCell(cell)
								cells.put(path, cell)
								val cellManager = context().actorOf(Props.create(GraphCellActor, cell), path.replace("/", "_"))
								cellManagers.put(path, cellManager)
							}
							if(it > 0) {
								val parent = actor.path().getElements().take(it).join("/")
								if(cells.containsKey(parent)) {
									graph.getModel().addEdge(cells.get(parent), cells.get(path))
								}
							}
						]
						graph.endUpdate()
						graph.layout(new AbegoTreeLayout(200, 200, Location.Bottom))
					]
				}
			].match(EventMessage) [
				val senderCell = cells.get(getEnvelope().sender().path().getElements().join("/"))
				val receiverCell = cells.get(getTarget().path().getElements().join("/"))
				val messageObj = getEnvelope().message()
				val message = if(messageObj instanceof IGraphic)
						messageObj.getNode()
					else
						new StackPane(new Circle(12) => [
							setFill(Color.AQUAMARINE)
						], new Text(getEnvelope().message().toString()))
				val path = new Path()
				path.getElements().add(new MoveTo(graph.getGraphic(senderCell).getLayoutX(), graph.getGraphic(senderCell).getLayoutY()))
				val lineTo = new LineTo()
				lineTo.xProperty().bind(graph.getGraphic(receiverCell).layoutXProperty())
				lineTo.yProperty().bind(graph.getGraphic(receiverCell).layoutYProperty())
				path.getElements().add(lineTo)

				Platform.runLater [
					graph.getCanvas().getChildren().add(message)
					new PathTransition(Duration.seconds(2), path, message) => [
						onFinished = [graph.getCanvas().getChildren().remove(message)]
						play()
					]
				]
				
				cellManagers.get(getTarget().path().getElements().join("/")).tell(it, self())
			].build()
		}

	}
	
	@FinalFieldsConstructor static class GraphCellActor extends AbstractActor {
		
		val ServerCell cell
		val statistics = new SummaryStatistics()
		
		override createReceive() {
			return receiveBuilder().match(EventMessage) [
				statistics.addValue(getQueueSize())
				val load = getQueueSize() / statistics.getMax()
				Platform.runLater[
					cell.getLoadProperty().set(load)
				]
			].build()
		}
		
	}

	@FinalFieldsConstructor static class ReceivedListActor extends AbstractActor {

		val ListView<EventMessage> listView

		override createReceive() {
			return receiveBuilder().match(EventMessage) [
				Platform.runLater [
					listView.getItems().add(it)
				]
			].build()
		}

	}

	@FinalFieldsConstructor @Accessors static class ServerCell extends AbstractCell {

		val String path
		val DoubleProperty loadProperty = new SimpleDoubleProperty()

		override getGraphic(Graph graph) {
			val pane = new BorderPane()
			pane.setStyle('''
			-fx-border-color: azure;
			-fx-border-width: 2px;
			-fx-background-color: rgb(5, 50, 58);
			-fx-text-fill: azure''')
			pane.setPrefSize(50, 50)
			
			new Text(path) => [
				setStyle("-fx-fill: azure;")
				BorderPane.setMargin(it, new Insets(10))
				BorderPane.setAlignment(it, Pos.CENTER)
				pane.setCenter(it)
			]
			
			new ProgressBar() => [
				progressProperty().bind(loadProperty)
				BorderPane.setAlignment(it, Pos.CENTER)
				pane.setBottom(it)
			]
			
			return pane
		}

	}

	static class DummyActor extends AbstractActor {
		
		val log = Logging.getLogger(getContext().getSystem(), this)

		override createReceive() {
			return receiveBuilder().matchAny [
				log.info(toString())
			].build()
		}

	}

	static interface IGraphic {

		def Node getNode()

	}

}
