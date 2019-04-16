package com.sirolf2009.muse

import akka.actor.ActorSystem
import com.sirolf2009.muse.client.ClientScreen
import com.typesafe.config.ConfigFactory
import javafx.application.Application
import javafx.scene.Scene
import javafx.stage.Stage
import akka.actor.Props
import com.sirolf2009.muse.client.MuseClientActor

class MuseClient extends Application {
	
	override start(Stage primaryStage) throws Exception {
		val system = ActorSystem.create("muse-client-system", ConfigFactory.load("client.conf"))
		
//		InternalMuse.startInternalMuse(system)
		
		val main = new ClientScreen()
		system.actorOf(Props.create(MuseClientActor, main), "muse-client")
		
		val scene = new Scene(main, 1024, 768)
		scene.getStylesheets().add("/styles.css")

		primaryStage.setScene(scene)
		primaryStage.show()
	}
	
	def static void main(String[] args) {
		launch(args)
	}
	
}