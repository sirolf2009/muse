package com.sirolf2009.muse.client

import akka.actor.ActorRef
import com.sirolf2009.muse.client.ConnectionTreeItem.Server
import com.sirolf2009.muse.client.ConnectionTreeItem.Servers
import javafx.scene.control.TreeCell
import javafx.scene.control.TreeItem
import javafx.scene.control.TreeView

class ConnectionTree extends TreeView<ConnectionTreeItem> {

	new() {
		super(new TreeItem(new Servers()))
		setPrefWidth(300)
		setShowRoot(false)
		setCellFactory [
			new TreeCell<ConnectionTreeItem>() {
				override protected updateItem(ConnectionTreeItem item, boolean empty) {
					super.updateItem(item, empty)
					setText(null)
					setGraphic(null)
					if(!empty && item !== null) {
						item.getText().ifPresent[text| setText(text)]
						item.getGraphic().ifPresent[graphic| setGraphic(graphic)]
						item.getContextMenu().ifPresent[context| setContextMenu(context)]
						item.getTooltip().ifPresent[tooltip| setTooltip(tooltip)]
					}
				}
			}
		]
	}
	
	def getServer(ActorRef actor) {
		getRoot().getChildren().stream().filter [
			getValue() instanceof Server
		].filter [
			(getValue() as Server).getActor().equals(actor)
		].findFirst()
	}

}
