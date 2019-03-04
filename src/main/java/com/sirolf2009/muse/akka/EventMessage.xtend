package com.sirolf2009.muse.akka

import akka.^dispatch.Envelope
import org.eclipse.xtend.lib.annotations.Data

@Data class EventMessage extends Event {
	
	val Envelope envelope
	
}