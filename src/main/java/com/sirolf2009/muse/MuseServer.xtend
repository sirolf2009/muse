package com.sirolf2009.muse

import akka.actor.AbstractActor
import akka.actor.ActorRef
import akka.actor.ActorSystem
import akka.actor.Props
import com.sirolf2009.muse.actorgraph.ActorGraph
import com.sirolf2009.muse.actorgraph.ActorGraphActor
import com.sirolf2009.muse.messagetable.MessageTable
import com.sirolf2009.muse.messagetable.MessageTableActor
import com.typesafe.config.ConfigFactory
import javafx.application.Application
import javafx.scene.Scene
import javafx.scene.control.SplitPane
import javafx.scene.control.TableView
import javafx.stage.Stage
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

class MuseServer extends Application {

	// TODO idea, listen for a subset of (or all) actors and plot their comms in a sequence diagram
	override start(Stage primaryStage) throws Exception {
		val main = new SplitPane() => [
			getStyleClass().add("map-background")
		]

		val graph = new ActorGraph()
		val table = new MessageTable()

		main.getItems().addAll(graph, table)

		val scene = new Scene(main, 1024, 768)
		scene.getStylesheets().add("/styles.css")
		val system = ActorSystem.create("muse-server-system", ConfigFactory.load("server.conf"))
		system.actorOf(Props.create(ServerActor, graph, table), "ServerActor")

		primaryStage.setScene(scene)
		primaryStage.show()
	}

	def static void main(String[] args) {
		launch(args)
	}

	@FinalFieldsConstructor static class ServerActor extends AbstractActor {

		val ActorGraph graph
		val TableView<EventMessage> table
		var ActorRef graphActor
		var ActorRef tableActor

		override preStart() throws Exception {
			graphActor = context().actorOf(Props.create(ActorGraphActor, graph), "Graph")
			tableActor = context().actorOf(Props.create(MessageTableActor, table), "Table")
		}

		override createReceive() {
			return receiveBuilder().match(Event) [
				graphActor.tell(it, self())
				tableActor.tell(it, self())
			].build()
		}

	}
	
	@Data static class FocusMessage {
		val EventMessage eventMessage
	}

}
