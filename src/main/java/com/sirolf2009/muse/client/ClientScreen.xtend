package com.sirolf2009.muse.client

import javafx.scene.control.Button
import javafx.scene.control.TabPane
import javafx.scene.control.TextField
import javafx.scene.layout.BorderPane
import javafx.scene.layout.HBox
import javafx.scene.layout.Priority
import javafx.scene.layout.VBox
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class ClientScreen extends BorderPane {
	
	val TabPane connections
	val TextField connectionURL
	val ConnectionTree connectionTree
	val Button connect

	new() {
		connections = new TabPane()
		setCenter(connections)
		
		connectionURL = new TextField("akka.tcp://muse-server-system@127.0.0.1:2552/user/ServerActor") => [
			HBox.setHgrow(it, Priority.ALWAYS)
			setId("connectionURL")
		]
		connectionTree = new ConnectionTree() => [
			VBox.setVgrow(it, Priority.ALWAYS)
			setId("connections")
		]
		connect = new Button("OK") => [
			setId("connect")
		]
		val connectionsPane = new VBox(new HBox(connectionURL, connect), connectionTree)
		setLeft(connectionsPane)
	}

}
