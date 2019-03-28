package com.sirolf2009.muse

import akka.actor.AbstractActor
import akka.actor.ActorRef
import akka.actor.ActorSystem
import akka.actor.Props
import com.typesafe.config.ConfigFactory
import java.util.ArrayList
import org.eclipse.xtend.lib.annotations.Data
import java.io.Serializable
import com.sirolf2009.muse.event.EventKill

class MuseStandalone {
	
	def static void main(String[] args) {
		val system = ActorSystem.create("muse-server-system", ConfigFactory.load("server.conf"))
		system.actorOf(Props.create(BufferActor), "ServerActor")
	}

	static class BufferActor extends AbstractActor {
		
		val spawns = new ArrayList<EventSpawn>()
		val connections = new ArrayList<ActorRef>()

		override createReceive() {
			return receiveBuilder().match(Event) [
				connections.forEach[conn|
					conn.tell(it, getSelf())
				]
				if(it instanceof EventSpawn) {
					spawns.add(it)
				} else if(it instanceof EventKill) {
					println("Received kill! "+it)
					spawns.remove(spawns.findFirst[spawn| spawn.actor.equals(actor)])
				}
			].match(Connect) [
				connections.add(actor)
				spawns.forEach[msg| actor.tell(msg, getSelf())]
			].build()
		}

	}
	
	@Data static class Connect implements Serializable {
		ActorRef actor
	}

}
