package com.sirolf2009.muse

import akka.actor.ActorSystem
import com.sirolf2009.muse.event.Event
import java.io.Serializable
import java.time.Duration
import java.util.HashMap
import java.util.UUID
import org.eclipse.xtend.lib.annotations.Data
import java.util.concurrent.TimeUnit

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
			try {
				val selection = system.actorSelection('''akka.tcp://«remoteActorSystem»@«host»:«port»/user/ServerActor''').resolveOne(Duration.ofSeconds(10)).toCompletableFuture().get(10, TimeUnit.SECONDS)
				val connectionID = UUID.randomUUID()
				selection.tell(new NewAppConnection(connectionID, system.name()), local)
				connectionMap.put(system, connectionID)
				system.eventStream().subscribe(selection, Event)
				system.getWhenTerminated().thenAcceptAsync [ termination |
					selection.tell(new DisconnectApp(connectionID), local)
				]
				Runtime.getRuntime().addShutdownHook(new Thread [
					selection.tell(new DisconnectApp(connectionID), local)
				])
			} catch(Exception e) {
				e.printStackTrace()
			}
		].toCompletableFuture().get()
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
