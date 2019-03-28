package com.sirolf2009.muse

import akka.actor.ActorSystem
import akka.actor.Props
import com.sirolf2009.muse.MuseStandalone.Connect
import com.typesafe.config.ConfigFactory
import java.time.Duration
import javafx.application.Application
import javafx.scene.Scene
import javafx.stage.Stage

class MuseClient extends Application {
	
	override start(Stage primaryStage) throws Exception {
		val system = ActorSystem.create("muse-client-system", ConfigFactory.load("client.conf"))
		val instance = new Instance()
		val instanceActor = system.actorOf(Props.create(InstanceActor, instance), "ServerActor")
		val serverActor = system.actorSelection("akka.tcp://muse-server-system@127.0.0.1:2552/user/ServerActor").resolveOne(Duration.ofSeconds(1)).toCompletableFuture().get()
		serverActor.tell(new Connect(instanceActor), instanceActor)
		
		val scene = new Scene(instance, 1024, 768)
		scene.getStylesheets().add("/styles.css")

		primaryStage.setScene(scene)
		primaryStage.show()
	}
	
	def static void main(String[] args) {
		launch(args)
	}
	
}