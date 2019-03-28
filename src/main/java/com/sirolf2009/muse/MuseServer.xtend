package com.sirolf2009.muse

import akka.actor.ActorSystem
import akka.actor.Props
import com.typesafe.config.ConfigFactory
import javafx.application.Application
import javafx.scene.Scene
import javafx.stage.Stage

class MuseServer extends Application {

	override start(Stage primaryStage) throws Exception {
		val system = ActorSystem.create("muse-server-system", ConfigFactory.load("server.conf"))
		val instance = new Instance()
		system.actorOf(Props.create(InstanceActor, instance), "ServerActor")
		
		val scene = new Scene(instance, 1024, 768)
		scene.getStylesheets().add("/styles.css")

		primaryStage.setScene(scene)
		primaryStage.show()
	}

	def static void main(String[] args) {
		launch(args)
	}

}
