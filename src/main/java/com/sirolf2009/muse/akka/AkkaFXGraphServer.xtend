package com.sirolf2009.muse.akka

import akka.actor.AbstractActor
import akka.actor.ActorRef
import akka.actor.ActorSystem
import akka.actor.Props
import akka.event.Logging
import com.fxgraph.graph.Graph
import com.fxgraph.layout.AbegoTreeLayout
import com.sirolf2009.muse.akka.server.graph.ServerCell
import com.typesafe.config.ConfigFactory
import java.util.HashMap
import java.util.Map
import java.util.Optional
import javafx.animation.PathTransition
import javafx.application.Application
import javafx.application.Platform
import javafx.geometry.Orientation
import javafx.scene.Node
import javafx.scene.Scene
import javafx.scene.control.Label
import javafx.scene.control.SplitPane
import javafx.scene.control.TableView
import javafx.scene.shape.LineTo
import javafx.scene.shape.MoveTo
import javafx.scene.shape.Path
import javafx.scene.text.Font
import javafx.stage.Stage
import javafx.util.Duration
import org.abego.treelayout.Configuration.Location
import org.apache.commons.math3.stat.descriptive.SummaryStatistics
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

class AkkaFXGraphServer extends Application {

	// TODO idea, listen for a subset of (or all) actors and plot their comms in a sequence diagram
	override start(Stage primaryStage) throws Exception {
		val main = new SplitPane() => [
			setOrientation(Orientation.VERTICAL)
			getStyleClass().add("map-background")
		]

		val graph = new Graph() => [
			getCanvas().getStyleClass().add("map-background")
		]
		val table = new EventMessageTable()
		val graphNew = new ActorGraph()

		main.getItems().addAll(graphNew, table)

		val scene = new Scene(main, 1024, 768)
		scene.getStylesheets().add("/styles.css")
		val system = ActorSystem.create("muse-server-system", ConfigFactory.load("server.conf"))
		val actor = system.actorOf(Props.create(ServerActor, graph, table), "ServerActor")
		system.eventStream().subscribe(actor, Event)
		val actorGraph = system.actorOf(Props.create(ActorGraphActor, graphNew), "ActorGraph")
		system.eventStream().subscribe(actorGraph, Event)

		primaryStage.setScene(scene)
		primaryStage.show()
	}

	def static void main(String[] args) {
		launch(args)
	}

	@FinalFieldsConstructor static class ServerActor extends AbstractActor {

		val Graph graph
		val TableView<EventMessage> table
		var ActorRef graphActor
		var ActorRef listActor

		override preStart() throws Exception {
			graphActor = context().actorOf(Props.create(GraphActor, graph), "Graph")
			listActor = context().actorOf(Props.create(ReceivedTableActor, table), "Table")
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

		val log = Logging.getLogger(getContext().getSystem(), this)
		val Graph graph
		val Map<String, ServerCell> cells = new HashMap()
		val Map<String, ActorRef> cellManagers = new HashMap()

		override createReceive() {
			return receiveBuilder().match(EventSpawn) [
				if(getActor().isDefined() && !cellManagers.values().contains(getActor().get())) {
					Platform.runLater [
						val actor = getActor().get()
						(0 ..< actor.path().elements().size()).forEach [
							val name = actor.path().getElements().get(it)
							val path = actor.path().getElements().take(it + 1).join("/")
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
						graph.getModel().getAllEdges().forEach[
							graph.getGraphic(it).toBack()
						]
					]
				}
			].match(EventMessage) [
				val senderPath = getEnvelope().sender().path().getElements().join("/")
				val senderCell = cells.get(senderPath)
				val receiverPath = getTarget().path().getElements().join("/")
				val receiverCell = cells.get(receiverPath)
				if(senderCell !== null && receiverCell !== null) {
					val messageObj = getEnvelope().message()
					val message = if(messageObj instanceof IGraphic)
							messageObj.getNode()
						else
							new Label(getEnvelope().message().toString()) => [
								setFont(new Font("Verdana", 8))
								setStyle('''
								-fx-background-color: aquamarine;
								-fx-background-radius: 16.4, 15;''')
							]
					val path = new Path()
					path.getElements().add(new MoveTo(graph.getGraphic(senderCell).getLayoutX(), graph.getGraphic(senderCell).getLayoutY()))
					val lineTo = new LineTo()
					lineTo.xProperty().bind(graph.getGraphic(receiverCell).layoutXProperty())
					lineTo.yProperty().bind(graph.getGraphic(receiverCell).layoutYProperty())
					path.getElements().add(lineTo)

					Platform.runLater [
						graph.getCanvas().getChildren().add(message)
						new PathTransition(Duration.seconds(1), path, message) => [
							onFinished = [graph.getCanvas().getChildren().remove(message)]
							play()
						]
					]

					cellManagers.get(receiverPath).tell(it, self())
				} else {
					log.error('''
					Failed to find corresponding receiver/sender.
					Message: «it»
					sender: «senderCell» «senderPath»
					receiver: «receiverCell» «receiverPath»
					cells: «cells»''')
				}
			].build()
		}
		
		override preRestart(Throwable reason, Optional<Object> message) throws Exception {
			log.error(reason, "GraphActor failed because of "+message)
		}

	}

	@FinalFieldsConstructor static class GraphCellActor extends AbstractActor {

		val ServerCell cell
		val statistics = new SummaryStatistics()

		override createReceive() {
			return receiveBuilder().match(EventMessage) [
				statistics.addValue(getQueueSize())
				val load = getQueueSize() / statistics.getMax()
				Platform.runLater [
					cell.getLoadProperty().set(load)
				]
			].build()
		}

	}

	@FinalFieldsConstructor static class ReceivedTableActor extends AbstractActor {

		val TableView<EventMessage> table

		override createReceive() {
			return receiveBuilder().match(EventMessage) [
				Platform.runLater [
					table.getItems().add(it)
				]
			].build()
		}

	}

	static class DummyActor extends AbstractActor {

		val log = Logging.getLogger(getContext().getSystem(), this)

		override createReceive() {
			return receiveBuilder().matchAny [
				log.info(toString())
				println("dummy actor printed")
			].build()
		}

	}

	static interface IGraphic {

		def Node getNode()

	}

}
