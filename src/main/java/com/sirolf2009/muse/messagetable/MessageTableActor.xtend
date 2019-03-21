package com.sirolf2009.muse.messagetable

import akka.actor.AbstractActor
import com.sirolf2009.muse.EventMessage
import javafx.application.Platform
import javafx.scene.control.TableView
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import com.sirolf2009.muse.MuseServer.FocusMessage
import javafx.scene.control.SelectionMode

@FinalFieldsConstructor class MessageTableActor extends AbstractActor {

	val TableView<EventMessage> table

	override preStart() throws Exception {
		table.getSelectionModel().setSelectionMode(SelectionMode.MULTIPLE)
		table.getSelectionModel().selectedItemProperty().addListener [ obs, oldVal, newVal |
			if(newVal !== null && table.getSelectionModel().getSelectedItems().size() == 1) {
				context().actorSelection("../*").tell(new FocusMessage(newVal), getSelf())
			}
		]
	}

	override createReceive() {
		return receiveBuilder().match(EventMessage) [
			Platform.runLater [
				table.getItems().add(it)
			]
		].match(FocusMessage) [
			if(getSender() != getSelf()) {
				Platform.runLater [
					table.getSelectionModel().select(getEventMessage())
				]
			}
		].build()
	}

}
