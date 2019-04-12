package com.sirolf2009.muse

import akka.actor.ActorSystem
import com.sirolf2009.muse.event.Event
import java.io.Serializable
import java.time.Duration
import java.util.HashMap
import java.util.UUID
import org.eclipse.xtend.lib.annotations.Data
import java.util.concurrent.TimeUnit
import akka.actor.ActorRef
import akka.event.Logging.LogEvent
import akka.actor.Props

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
		connect(system, system.actorSelection('''akka.tcp://«remoteActorSystem»@«host»:«port»/user/ServerActor''').resolveOne(duration).toCompletableFuture().get(duration.toMillis(), TimeUnit.MILLISECONDS))
	}

	def static connect(ActorSystem system, ActorRef remoteActor) {
		system.actorSelection("/").resolveOne(Duration.ofSeconds(1)).thenAccept [ local |
			try {
				val connectionID = UUID.randomUUID()
				remoteActor.tell(new NewAppConnection(connectionID, system.name()), local)
				connectionMap.put(system, connectionID)
				system.eventStream().subscribe(remoteActor, Event)
				val loggingActor = system.actorOf(Props.create(MuseLoggingAdapter), "muse-logging")
				system.eventStream().subscribe(loggingActor, LogEvent)
				
				system.getWhenTerminated().thenAcceptAsync [ termination |
					remoteActor.tell(new DisconnectApp(connectionID), local)
				]
				Runtime.getRuntime().addShutdownHook(new Thread [
					remoteActor.tell(new DisconnectApp(connectionID), local)
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
