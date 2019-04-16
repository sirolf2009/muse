package com.sirolf2009.muse.standalone.kafka

import akka.actor.AbstractActor
import akka.actor.ActorRef
import akka.actor.ActorSystem
import akka.actor.Address
import akka.actor.Props
import akka.event.Logging
import akka.event.Logging.LogEvent
import com.sirolf2009.muse.MuseConnect.DisconnectApp
import com.sirolf2009.muse.MuseConnect.NewAppConnection
import com.sirolf2009.muse.MuseStandalone.Connections
import com.sirolf2009.muse.MuseStandalone.GetConnections
import com.sirolf2009.muse.event.Event
import java.util.ArrayList
import java.util.HashMap
import java.util.UUID
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import com.sirolf2009.muse.MuseStandalone.SubscribeToConnections
import com.sirolf2009.muse.MuseStandalone.UnsubscribeFromConnections

@FinalFieldsConstructor class KafkaBuffersActor extends AbstractActor {


  	val log = Logging.getLogger(getContext().getSystem(), this)
	val connections = new ArrayList<NewAppConnection>()
	val actorsByID = new HashMap<UUID, ActorRef>
	val actorsByAddress = new HashMap<Address, ActorRef>
	val connectionSubscribers = new ArrayList<ActorRef>()
	val ActorSystem system
	val String topicNamePrefix

	override createReceive() {
		return receiveBuilder().match(NewAppConnection) [
			log.info('''New «getActorSystem()» app connection from «getSender().path().address()» as «getID()»''')
			val actor = context().actorOf(Props.create(KafkaBufferActor, it, system, topicNamePrefix+"_"+actorSystem+"_"+ID), ID.toString())
			actorsByID.put(ID, actor)
			actorsByAddress.put(actor.path().address(), actor)
			connections.add(it)
			connectionSubscribers.forEach[sub|sub.tell(new Connections(connections), getSelf())]
		].match(DisconnectApp) [
			log.info('''Disconnecting app «getID()»''')
			val actor = actorsByID.get(ID)
			context().stop(actor)
			connections.remove(connections.findFirst[conn| conn.getID().equals(ID)])
			connectionSubscribers.forEach[sub|sub.tell(new Connections(connections), getSelf())]
		].match(GetConnections) [
			log.info('''Getting connections: «getSender()»''')
			getSender().tell(new Connections(connections), getSelf())
		].match(SubscribeToConnections) [
			log.info('''Subcribed to connections: «getSender()»''')
			connectionSubscribers.add(getSender())
		].match(UnsubscribeFromConnections) [
			log.info('''Unsubcribed from connections: «getSender()»''')
			connectionSubscribers.remove(getSender())
		].match(Event) [
			actorsByID.get(getConnectionID()).tell(it, getSender())
		].match(LogEvent) [
			actorsByAddress.get(sender().path().address()).tell(it, getSender())
		].build()
	}

}
