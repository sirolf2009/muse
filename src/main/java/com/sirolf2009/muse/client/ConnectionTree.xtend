package com.sirolf2009.muse.client

import akka.actor.ActorRef
import akka.actor.ActorSystem
import akka.actor.Props
import akka.pattern.Patterns
import com.sirolf2009.muse.Instance
import com.sirolf2009.muse.InstanceActor
import com.sirolf2009.muse.MuseStandalone.Connect
import com.sirolf2009.muse.MuseStandalone.Connections
import com.sirolf2009.muse.MuseStandalone.Disconnect
import com.sirolf2009.muse.MuseStandalone.GetConnections
import com.sirolf2009.muse.client.ConnectionTreeItem.Connection
import com.sirolf2009.muse.client.ConnectionTreeItem.Server
import com.sirolf2009.muse.client.ConnectionTreeItem.Servers
import java.time.Duration
import javafx.application.Platform
import javafx.scene.control.Tab
import javafx.scene.control.TabPane
import javafx.scene.control.TreeCell
import javafx.scene.control.TreeItem
import javafx.scene.control.TreeView

class ConnectionTree extends TreeView<ConnectionTreeItem> {

	new(ActorSystem system, TabPane connections) {
		super(new TreeItem(new Servers()))
		setPrefWidth(300)
		setShowRoot(false)
		setOnMouseClicked [
			if(getClickCount() == 2) {
				val node = getSelectionModel().getSelectedItem()
				val item = node.getValue()
				if(item instanceof Connection) {
					val server = node.getParent().getValue() as Server
					system.actorSelection(server.actor.path().child(item.getConnection().getID().toString())).resolveOne(Duration.ofSeconds(10)).thenAccept [
						val instance = new Instance()
						val instanceActor = system.actorOf(Props.create(InstanceActor, instance), "ClientActor")
						tell(new Connect(instanceActor), instanceActor)
						Platform.runLater [
							item.connected.set(true)
							val tab = new Tab(item.getConnection().getActorSystem(), instance)
							connections.getTabs().add(tab)
							connections.getSelectionModel().select(tab)
							tab.setOnClosed [evt|
								item.connected.set(false)
								tell(new Disconnect(instanceActor), instanceActor)
								system.stop(instanceActor)
							]
						]
					]
				}
			}
		]
		setCellFactory [
			new TreeCell<ConnectionTreeItem>() {
				override protected updateItem(ConnectionTreeItem item, boolean empty) {
					super.updateItem(item, empty)
					setText(null)
					setGraphic(null)
					if(!empty && item !== null) {
						item.getText().ifPresent[text| setText(text)]
						item.getGraphic().ifPresent[graphic| setGraphic(graphic)]
					}
				}
			}
		]
	}

	def connectWith(ActorRef buffersActor) {
		Patterns.ask(buffersActor, new GetConnections(), Duration.ofSeconds(10)).thenAccept [
			val msg = it as Connections
			val connections = msg.connections.map[new Connection(it)].toList()
			val connectionTreeItems = connections.map[new TreeItem<ConnectionTreeItem>(it)].toList()
			val server = new Server(buffersActor)
			val serverTreeItem = new TreeItem<ConnectionTreeItem>(server)
			serverTreeItem.getChildren().addAll(connectionTreeItems)
			getRoot().getChildren().add(serverTreeItem)
		]
	}

}
