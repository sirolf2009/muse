package com.sirolf2009.muse

import akka.actor.AbstractActor
import akka.actor.ActorRef
import akka.actor.ActorSystem
import akka.actor.Props
import akka.event.Logging.LogEvent
import com.sirolf2009.muse.MuseConnect.DisconnectApp
import com.sirolf2009.muse.MuseConnect.NewAppConnection
import com.sirolf2009.muse.event.Event
import java.util.HashMap
import java.util.UUID
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor class MuseAppClientActor extends AbstractActor {
	
	static val connectionMap = new HashMap<ActorSystem, UUID>()

	val ActorRef remoteActor
	val UUID connectionID = UUID.randomUUID()
	var ActorRef logging

	override preStart() throws Exception {
		connectionMap.put(context().system(), connectionID)
		
		remoteActor.tell(new NewAppConnection(connectionID, context().system().name()), getSelf())
		//TODO simply subscribing to events makes running multiple muses hard (i.e. muse-client and muse-internal) as they'll both get each others messages.
		//Perhaps it would be better to not subscribe, but send them directly to the target
		//Or, we do subscribe, but we include a field in every Event who their target is and then the target needs to filter out messages that aren't his
		context().system().eventStream().subscribe(remoteActor, Event)
		
		logging = context().actorOf(Props.create(MuseLoggingAdapter), "logging")
		context().system().eventStream().subscribe(logging, LogEvent)
	}
	
	override postStop() throws Exception {
		remoteActor.tell(new DisconnectApp(connectionID), getSelf())
	}

	override createReceive() {
		return receiveBuilder().matchEquals("initialized?") [
			getSender().tell(true, getSelf())
		].build()
	}

	def static getConnection(ActorSystem system) {
		return connectionMap.get(system)
	}

}
