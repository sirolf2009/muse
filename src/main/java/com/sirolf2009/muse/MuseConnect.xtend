package com.sirolf2009.muse

import akka.actor.ActorRef
import akka.actor.ActorSystem
import akka.actor.Props
import akka.pattern.Patterns
import java.io.Serializable
import java.time.Duration
import java.util.Date
import java.util.UUID
import java.util.concurrent.TimeUnit
import org.eclipse.xtend.lib.annotations.Data

class MuseConnect {

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
		val museClient = system.actorOf(Props.create(MuseAppClientActor, remoteActor), "muse")
		if(!Patterns.ask(museClient, "initialized?", Duration.ofSeconds(1)).toCompletableFuture().get() as Boolean) {
			throw new RuntimeException("Muse failed to initialize")
		}
	}

	@Data static class NewAppConnection implements Serializable {
		UUID ID
		String actorSystem
		Date timestamp = new Date()
	}

	@Data static class DisconnectApp implements Serializable {
		UUID ID
	}

}
