package com.sirolf2009.muse

import akka.actor.ActorSystem
import java.io.Serializable
import java.time.Duration
import java.util.HashMap
import java.util.UUID
import org.eclipse.xtend.lib.annotations.Data

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
		system.actorSelection("/").resolveOne(Duration.ofSeconds(1)).thenAccept [ local |
			val selection = system.actorSelection('''akka.tcp://«remoteActorSystem»@«host»:«port»/user/*''')
			selection.resolveOne(duration).toCompletableFuture().thenAccept [
				val connectionID = UUID.randomUUID()
				tell(new NewAppConnection(connectionID, system.name()), local)
				connectionMap.put(system, connectionID)
				system.eventStream().subscribe(it, Event)
				system.getWhenTerminated().thenAcceptAsync [ termination |
					println("sending disconnect message")
					tell(new DisconnectApp(connectionID), local)
				]
				Runtime.getRuntime().addShutdownHook(new Thread [
					println("sending disconnect message")
					tell(new DisconnectApp(connectionID), local)
				])
			].get()
		]
	}

	def static getConnection(ActorSystem system) {
		return connectionMap.get(system)
	}

	@Data static class NewAppConnection implements Serializable {
		UUID ID
		String actorSystem
	}

	@Data static class DisconnectApp implements Serializable {
		UUID ID
	}

}
