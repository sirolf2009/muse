package com.sirolf2009.muse

import akka.actor.AbstractActor
import akka.actor.ActorRef
import akka.actor.Props
import com.sirolf2009.muse.actorgraph.ActorGraphActor
import com.sirolf2009.muse.event.Event
import com.sirolf2009.muse.event.EventMessage
import com.sirolf2009.muse.messagetable.MessagesActor
import com.sirolf2009.muse.sequencediagram.SequenceDiagramActor
import java.io.Serializable
import javafx.application.Platform
import javafx.scene.Node
import javafx.scene.control.Tab
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor class InstanceActor extends AbstractActor {

	val Instance instance
	var ActorRef graphActor
	var ActorRef messagesActor
	var ActorRef sequenceDiagramActor

	override preStart() throws Exception {
		graphActor = context().actorOf(Props.create(ActorGraphActor, instance.getGraph()), "Graph")
		sequenceDiagramActor = context().actorOf(Props.create(SequenceDiagramActor, getSelf()), "SequenceDiagram")
		messagesActor = context().actorOf(Props.create(MessagesActor, instance.getTable(), sequenceDiagramActor), "Messages")
	}

	override createReceive() {
		return receiveBuilder().match(Event) [
			graphActor.tell(it, self())
			messagesActor.tell(it, self())
		].match(ShowScreen) [
			Platform.runLater [
				val tab = new Tab(name, node)
				instance.getMainView().getTabs().add(tab)
				instance.getMainView().getSelectionModel().select(tab)
			]
		].build()
	}
	
	@Data static class FocusMessage implements Serializable {
		val EventMessage eventMessage
	}
	@Data static class ShowScreen implements Serializable {
		val String name
		val Node node
	}

}
