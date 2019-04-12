package com.sirolf2009.muse.standalone.kafka

import akka.actor.AbstractActor
import akka.actor.ActorRef
import akka.actor.ActorSystem
import akka.actor.Props
import com.sirolf2009.muse.MuseConnect.DisconnectApp
import com.sirolf2009.muse.MuseConnect.NewAppConnection
import com.sirolf2009.muse.MuseStandalone.Connections
import com.sirolf2009.muse.MuseStandalone.GetConnections
import com.sirolf2009.muse.event.Event
import java.util.ArrayList
import java.util.HashMap
import java.util.UUID
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import akka.actor.Address
import akka.event.Logging.LogEvent

@FinalFieldsConstructor class KafkaBuffersActor extends AbstractActor {

	val connections = new ArrayList<NewAppConnection>()
	val actorsByID = new HashMap<UUID, ActorRef>
	val actorsByAddress = new HashMap<Address, ActorRef>
	val ActorSystem system
	val String topicNamePrefix

	override createReceive() {
		return receiveBuilder().match(NewAppConnection) [
			getSender().path().address()
			val actor = context().actorOf(Props.create(KafkaBufferActor, system, topicNamePrefix+"_"+actorSystem+"_"+ID), ID.toString())
			actorsByID.put(ID, actor)
			actorsByAddress.put(actor.path().address(), actor)
			connections.add(it)
		].match(DisconnectApp) [
			val actor = actorsByID.get(ID)
			context().stop(actor)
			connections.remove(connections.findFirst[conn| conn.getID().equals(ID)])
		].match(GetConnections) [
			getSender().tell(new Connections(connections), getSelf())
		].match(Event) [
			actorsByID.get(getConnectionID()).tell(it, getSender())
		].match(LogEvent) [
			actorsByAddress.get(sender().path().address()).tell(it, getSender())
		].build()
	}

}
