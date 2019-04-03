package com.sirolf2009.muse.standalone.kafka

import akka.actor.AbstractActor
import akka.actor.ActorRef
import akka.actor.ActorSystem
import akka.actor.Props
import com.sirolf2009.muse.Event
import com.sirolf2009.muse.MuseConnect.DisconnectApp
import com.sirolf2009.muse.MuseConnect.NewAppConnection
import com.sirolf2009.muse.MuseStandalone.Connections
import com.sirolf2009.muse.MuseStandalone.GetConnections
import java.util.ArrayList
import java.util.HashMap
import java.util.UUID
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor class KafkaBuffersActor extends AbstractActor {

	val connections = new ArrayList<NewAppConnection>()
	val actors = new HashMap<UUID, ActorRef>
	val ActorSystem system
	val String topicNamePrefix

	override createReceive() {
		return receiveBuilder().match(NewAppConnection) [
			val actor = context().actorOf(Props.create(KafkaBufferActor, system, topicNamePrefix+"_"+actorSystem+"_"+ID), ID.toString())
			actors.put(ID, actor)
			connections.add(it)
		].match(DisconnectApp) [
			val actor = actors.get(ID)
			context().stop(actor)
			connections.remove(connections.findFirst[conn| conn.getID().equals(ID)])
		].match(GetConnections) [
			getSender().tell(new Connections(connections), getSelf())
		].match(Event) [
			actors.get(getConnectionID()).tell(it, getSender())
		].build()
	}

}
