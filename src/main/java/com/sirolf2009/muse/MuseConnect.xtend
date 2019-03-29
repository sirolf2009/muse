package com.sirolf2009.muse

import akka.actor.ActorSystem
import java.io.Serializable
import java.time.Duration
import java.util.HashMap
import java.util.UUID
import org.eclipse.xtend.lib.annotations.Data
import akka.actor.ActorRef

class MuseConnect {
	
	static val connectionMap = new HashMap<ActorSystem, UUID>()
	
	def static connect(ActorSystem system) {
		connect(system, "127.0.0.1", 2552)
	}
	
	def static connect(ActorSystem system, String host, int port) {
		connect(system, "muse-server-system", host, port)
	}
	
	def static connect(ActorSystem system, String remoteActorSystem, String host, int port) {
		connect(system, remoteActorSystem, host, port, Duration.ofSeconds(10))
	}
	
	def static connect(ActorSystem system, String remoteActorSystem, String host, int port, Duration duration) {
		val selection = system.actorSelection('''akka.tcp://«remoteActorSystem»@«host»:«port»/user/ServerActor''')
		selection.resolveOne(duration).toCompletableFuture().thenAccept[
			val connectionID = UUID.randomUUID()
			selection.tell(new NewConnection(connectionID, system.name()), ActorRef.noSender())
			connectionMap.put(system, connectionID)
			system.eventStream().subscribe(it, Event)
		].get()
	}
	
	def static getConnection(ActorSystem system) {
		return connectionMap.get(system)
	}
	
	@Data static class NewConnection implements Serializable {
		UUID ID
		String actorSystem
	}
	
}