package com.sirolf2009.muse

import akka.actor.AbstractActor
import akka.actor.ActorRef
import akka.actor.ActorSystem
import akka.actor.Props
import com.sirolf2009.muse.MuseConnect.NewConnection
import com.sirolf2009.muse.event.EventKill
import com.typesafe.config.ConfigFactory
import java.io.Serializable
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.UUID
import org.eclipse.xtend.lib.annotations.Data

class MuseStandalone {
	
	def static void main(String[] args) {
		val system = ActorSystem.create("muse-server-system", ConfigFactory.load("server.conf"))
		system.actorOf(Props.create(BuffersActor), "ServerActor")
	}
	
	static class BuffersActor extends AbstractActor {
		
		val connections = new ArrayList<NewConnection>()
		val actors = new HashMap<UUID, ActorRef>
		
		override createReceive() {
			return receiveBuilder().match(NewConnection) [
				val actor = context().actorOf(Props.create(BufferActor), ID.toString())
				actors.put(ID, actor)
				connections.add(it)
			].match(GetConnections)[
				getSender().tell(new Connections(connections), getSelf())
			].match(Event) [
				actors.get(getConnectionID()).tell(it, getSender())
			].build()
		}
		
	}
	
	@Data static class GetConnections implements Serializable {
	}
	
	@Data static class Connections implements Serializable {
		List<NewConnection> connections
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
					spawns.remove(spawns.findFirst[spawn| spawn.actor.equals(actor)])
				}
			].match(Connect) [
				connections.add(actor)
				spawns.forEach[msg| actor.tell(msg, getSelf())]
			].match(Disconnect) [
				connections.remove(actor)
			].build()
		}

	}
	
	@Data static class Connect implements Serializable {
		ActorRef actor
	}
	@Data static class Disconnect implements Serializable {
		ActorRef actor
	}

}
