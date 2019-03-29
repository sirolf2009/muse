package com.sirolf2009.muse.client

import akka.actor.ActorSystem
import java.time.Duration
import javafx.scene.control.Button
import javafx.scene.control.TabPane
import javafx.scene.control.TextField
import javafx.scene.layout.BorderPane
import javafx.scene.layout.HBox
import javafx.scene.layout.Priority
import javafx.scene.layout.VBox

class ClientScreen extends BorderPane {

	new(ActorSystem actorSystem) {
		val connections = new TabPane()		
		setCenter(connections)
		
		val connectionURL = new TextField("akka.tcp://muse-server-system@127.0.0.1:2552/user/ServerActor") => [
			HBox.setHgrow(it, Priority.ALWAYS)
		]
		val connectionTree = new ConnectionTree(actorSystem, connections) => [
			VBox.setVgrow(it, Priority.ALWAYS)
		]
		val connect = new Button("OK") => [
			setOnAction [
				actorSystem.actorSelection(connectionURL.getText()).resolveOne(Duration.ofSeconds(10)).thenAccept [
					connectionTree.connectWith(it)
				]
			]
		]
		val connectionsPane = new VBox(new HBox(connectionURL, connect), connectionTree)
		setLeft(connectionsPane)
	}

}
