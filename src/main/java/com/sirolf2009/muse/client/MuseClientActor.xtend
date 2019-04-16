package com.sirolf2009.muse.client

import akka.actor.AbstractActor
import akka.actor.ActorRef
import akka.actor.Props
import com.sirolf2009.muse.Instance
import com.sirolf2009.muse.InstanceActor
import com.sirolf2009.muse.MuseStandalone.Connect
import com.sirolf2009.muse.MuseStandalone.Connections
import com.sirolf2009.muse.MuseStandalone.Disconnect
import com.sirolf2009.muse.MuseStandalone.GetConnections
import com.sirolf2009.muse.MuseStandalone.SubscribeToConnections
import com.sirolf2009.muse.client.ConnectionTreeItem.Connection
import com.sirolf2009.muse.client.ConnectionTreeItem.Server
import java.io.Serializable
import java.time.Duration
import javafx.application.Platform
import javafx.scene.control.Tab
import javafx.scene.control.TreeItem
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import static extension com.sirolf2009.util.OptionalUtil.*

@FinalFieldsConstructor class MuseClientActor extends AbstractActor {

	val ClientScreen screen

	override preStart() throws Exception {
		screen.getConnect() => [
			setOnAction [
				context().actorSelection(screen.getConnectionURL().getText()).resolveOne(Duration.ofSeconds(10)).thenAccept [
					getSelf().tell(new ConnectToServer(it), getSelf())
				]
			]
		]
		screen.getConnectionTree() => [
			setOnMouseClicked [ evt |
				if(evt.getClickCount() == 2) {
					val node = getSelectionModel().getSelectedItem()
					val item = node.getValue()
					if(item instanceof Connection) {
						val server = node.getParent().getValue() as Server
						context().actorSelection(server.actor.path().child(item.getConnection().getID().toString())).resolveOne(Duration.ofSeconds(10)).thenAccept [
							val instance = new Instance()
							val instanceActor = context().actorOf(Props.create(InstanceActor, instance), "InstanceActor")
							tell(new Connect(instanceActor), instanceActor)
							Platform.runLater [
								item.connected.set(true)
								val tab = new Tab(item.getConnection().getActorSystem(), instance)
								screen.getConnections().getTabs().add(tab)
								screen.getConnections().getSelectionModel().select(tab)
								tab.setOnClosed [ evt2 |
									item.connected.set(false)
									tell(new Disconnect(instanceActor), instanceActor)
									context().stop(instanceActor)
								]
							]
						]
					}
				}
			]
		]
	}

	override createReceive() {
		return receiveBuilder().match(ConnectToServer) [
			serverActor.tell(new GetConnections(), getSelf())
			serverActor.tell(new SubscribeToConnections(), getSelf())
		].match(Connections) [
			val connections = connections.map[new Connection(it)].toList()
			screen.getConnectionTree().getServer(getSender()).consume([ existing |
				val itemsToAdd = connections.filter[existing.getChildren().findFirst[conn|(conn.getValue() as Connection).getConnection().equals(getConnection())] === null].map[new TreeItem<ConnectionTreeItem>(it)].toList()
				val itemsToRemove = existing.getChildren().filter[connections.findFirst[conn|conn.getConnection().equals((getValue() as Connection).getConnection())] === null].toList()
				Platform.runLater [
					existing.getChildren().removeAll(itemsToRemove)
					existing.getChildren().addAll(itemsToAdd)
				]
			], [
				val connectionTreeItems = connections.map[new TreeItem<ConnectionTreeItem>(it)].toList()
				val server = new Server(getSender())
				val serverTreeItem = new TreeItem<ConnectionTreeItem>(server)
				Platform.runLater [
					serverTreeItem.getChildren().addAll(connectionTreeItems)
					screen.getConnectionTree().getRoot().getChildren().add(serverTreeItem)
				]
			])
		].build()
	}

	@Data static class ConnectToServer implements Serializable {
		ActorRef serverActor
	}

}
