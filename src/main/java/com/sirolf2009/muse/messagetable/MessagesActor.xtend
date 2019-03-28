package com.sirolf2009.muse.messagetable

import akka.actor.AbstractActor
import akka.actor.ActorRef
import akka.actor.Props
import com.sirolf2009.muse.EventMessage
import com.sirolf2009.muse.InstanceActor.FocusMessage
import com.sirolf2009.muse.sequencediagram.SequenceDiagramActor.ShowSequenceDiagram
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor class MessagesActor extends AbstractActor {

	val Messages messages
	val ActorRef sequenceDiagramActor
	var ActorRef tableActor

	override preStart() throws Exception {
		tableActor = context().actorOf(Props.create(MessageTableActor, messages.getMessageTable()), "table")
		
		messages.getShowSequenceDiagram().setOnAction [
			sequenceDiagramActor.tell(new ShowSequenceDiagram(messages.getMessageTable().getSelectionModel().getSelectedItems()), getSelf())
		]
	}

	override createReceive() {
		return receiveBuilder().match(EventMessage) [
			tableActor.tell(it, getSelf())
		].match(FocusMessage) [
			tableActor.tell(it, getSelf())
		].build()
	}

}
