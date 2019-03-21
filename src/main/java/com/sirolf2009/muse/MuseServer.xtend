package com.sirolf2009.muse

import akka.actor.AbstractActor
import akka.actor.ActorRef
import akka.actor.ActorSystem
import akka.actor.Props
import com.sirolf2009.muse.actorgraph.ActorGraph
import com.sirolf2009.muse.actorgraph.ActorGraphActor
import com.sirolf2009.muse.messagetable.Messages
import com.sirolf2009.muse.messagetable.MessagesActor
import com.typesafe.config.ConfigFactory
import javafx.application.Application
import javafx.scene.Node
import javafx.scene.Scene
import javafx.scene.control.SplitPane
import javafx.scene.control.Tab
import javafx.scene.control.TabPane
import javafx.stage.Stage
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import javafx.application.Platform
import com.sirolf2009.muse.sequencediagram.SequenceDiagramActor

class MuseServer extends Application {

	// TODO idea, listen for a subset of (or all) actors and plot their comms in a sequence diagram
	override start(Stage primaryStage) throws Exception {
		val main = new SplitPane() => [
			getStyleClass().add("map-background")
		]

		val mainView = new TabPane()
		val graph = new ActorGraph()
		mainView.getTabs().add(new Tab("Actor Graph", graph) => [
			setClosable(false)
		])
		val table = new Messages()

		main.getItems().addAll(mainView, table)

		val scene = new Scene(main, 1024, 768)
		scene.getStylesheets().add("/styles.css")
		val system = ActorSystem.create("muse-server-system", ConfigFactory.load("server.conf"))
		system.actorOf(Props.create(ServerActor, mainView, graph, table), "ServerActor")

		primaryStage.setScene(scene)
		primaryStage.show()
	}

	def static void main(String[] args) {
		launch(args)
	}

	@FinalFieldsConstructor static class ServerActor extends AbstractActor {

		val TabPane mainView
		val ActorGraph graph
		val Messages messages
		var ActorRef graphActor
		var ActorRef messagesActor
		var ActorRef sequenceDiagramActor

		override preStart() throws Exception {
			graphActor = context().actorOf(Props.create(ActorGraphActor, graph), "Graph")
			sequenceDiagramActor = context().actorOf(Props.create(SequenceDiagramActor, getSelf()), "SequenceDiagram")
			messagesActor = context().actorOf(Props.create(MessagesActor, messages, sequenceDiagramActor), "Messages")
		}

		override createReceive() {
			return receiveBuilder().match(Event) [
				graphActor.tell(it, self())
				messagesActor.tell(it, self())
			].match(ShowScreen) [
				Platform.runLater[
					val tab = new Tab(name, node)
					mainView.getTabs().add(tab)
					mainView.getSelectionModel().select(tab)
				]
			].build()
		}

	}
	
	@Data static class FocusMessage {
		val EventMessage eventMessage
	}
	@Data static class ShowScreen {
		val String name
		val Node node
	}

}
