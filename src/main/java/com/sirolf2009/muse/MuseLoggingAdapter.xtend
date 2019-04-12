package com.sirolf2009.muse

import akka.actor.AbstractActor
import akka.event.Logging
import akka.event.Logging.InitializeLogger
import akka.event.Logging.LogEvent
import com.sirolf2009.muse.event.EventLog
import java.util.Date
import java.time.Duration

class MuseLoggingAdapter extends AbstractActor {

	override createReceive() {
		return receiveBuilder().match(InitializeLogger, [
			getSender().tell(Logging.loggerInitialized(), getSelf())
		]).match(LogEvent, [
			context().actorSelection(logSource()).resolveOne(Duration.ofSeconds(1)).toCompletableFuture().thenAcceptAsync [ sender |
				context().system().eventStream().publish(new EventLog(context().system(), new Date(), sender, new Date(timestamp()), level(), thread().getName(), message().toString()))
			]
		]).build()
	}

}
