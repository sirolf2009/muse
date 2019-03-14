package com.sirolf2009.muse

import akka.actor.AbstractActor
import akka.actor.ActorRef
import akka.actor.ActorSystem
import akka.actor.Props
import akka.event.Logging
import com.sirolf2009.muse.actorgraph.ActorGraph
import com.sirolf2009.muse.actorgraph.ActorGraphActor
import com.typesafe.config.ConfigFactory
import javafx.application.Application
import javafx.application.Platform
import javafx.geometry.Orientation
import javafx.scene.Scene
import javafx.scene.control.SplitPane
import javafx.scene.control.TableView
import javafx.stage.Stage
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

class MuseServer extends Application {

	// TODO idea, listen for a subset of (or all) actors and plot their comms in a sequence diagram
	override start(Stage primaryStage) throws Exception {
		val main = new SplitPane() => [
			setOrientation(Orientation.VERTICAL)
			getStyleClass().add("map-background")
		]

		val graph = new ActorGraph()
		val table = new EventMessageTable()

		main.getItems().addAll(graph, table)

		val scene = new Scene(main, 1024, 768)
		scene.getStylesheets().add("/styles.css")
		val system = ActorSystem.create("muse-server-system", ConfigFactory.load("server.conf"))
		system.actorOf(Props.create(ServerActor, table), "ServerActor")
		system.actorOf(Props.create(ActorGraphActor, graph), "ActorGraph")

		primaryStage.setScene(scene)
		primaryStage.show()
	}

	def static void main(String[] args) {
		launch(args)
	}

	@FinalFieldsConstructor static class ServerActor extends AbstractActor {

		val TableView<EventMessage> table
		var ActorRef listActor

		override preStart() throws Exception {
			listActor = context().actorOf(Props.create(ReceivedTableActor, table), "Table")
		}

		override createReceive() {
			return receiveBuilder().match(EventMessage) [
				listActor.tell(it, self())
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
			].build()
		}

	}

}
