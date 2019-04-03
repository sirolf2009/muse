package com.sirolf2009.muse.event

import akka.actor.ActorRef
import akka.^dispatch.Envelope
import org.eclipse.xtend.lib.annotations.Data

@Data class EventMessage extends Event {
	
	val Envelope envelope
	val ActorRef target
	val int queueSize
	
}