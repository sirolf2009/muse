package com.sirolf2009.muse.sequencediagram

import akka.actor.AbstractActor
import akka.actor.ActorRef
import com.fxgraph.graph.SequenceDiagram
import com.fxgraph.graph.SequenceDiagram.ActorCell
import com.fxgraph.graph.SequenceDiagram.MessageEdge
import com.sirolf2009.muse.EventMessage
import com.sirolf2009.muse.MuseServer.ShowScreen
import java.util.List
import java.util.stream.Collectors
import java.util.stream.Stream
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor class SequenceDiagramActor extends AbstractActor {
	
	val ActorRef serverActor
	
	override createReceive() {
		return receiveBuilder().match(ShowSequenceDiagram) [
			val seqDiagram = new SequenceDiagram()
			val messageCount = messages.size()
			val actors = messages.stream().flatMap[
				Stream.of(getEnvelope().sender(), getTarget())
			].distinct().map[
				path().getElements().last()
			].collect(Collectors.toMap([it], [new ActorCell(it, (messageCount * 50).doubleValue())]))
			actors.values().forEach[seqDiagram.addActor(it)]
			
			messages.stream().map[
				val from = actors.get(getEnvelope().sender().path().getElements().last())
				val to = actors.get(getTarget().path().getElements().last())
				new MessageEdge(from, to, getEnvelope().message().toString())
			].forEach[
				seqDiagram.addMessage(it)
			]
			
			seqDiagram.endUpdate()
			seqDiagram.layout()
			serverActor.tell(new ShowScreen("Sequence Diagram", seqDiagram.getCanvas()), getSelf())
		].build()
	}
	
	@Data static class ShowSequenceDiagram {
		val List<EventMessage> messages
	}
	
}