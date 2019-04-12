package com.sirolf2009.muse.event

import akka.actor.ActorRef
import java.util.Date
import org.eclipse.xtend.lib.annotations.Data

@Data class EventLog extends Event {
	
	val ActorRef actor
	val Date timestamp
	val int logLevel
	val String thread
	val String msg
	
}