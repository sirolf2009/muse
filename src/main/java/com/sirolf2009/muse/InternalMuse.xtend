package com.sirolf2009.muse

import akka.actor.ActorSystem
import akka.actor.Props
import javafx.application.Application
import javafx.scene.Scene
import javafx.stage.Stage

class InternalMuse extends Application {
	
	//TODO check if javafx is initialized, if so spawn a new stage. If not, launch InternalMuse as an application
	
	def static startInternalMuse(ActorSystem system) {
		val instance = new Instance()
		val instanceActor = system.actorOf(Props.create(InternalInstanceActor, instance), "muse-debug")
		new Stage() => [
			setScene(new Scene(instance) => [
				getStylesheets().add("/styles.css")
			])
			show()
		]
		MuseConnect.connect(system, instanceActor)
	}
	
	override start(Stage primaryStage) throws Exception {
		
	}
	
}