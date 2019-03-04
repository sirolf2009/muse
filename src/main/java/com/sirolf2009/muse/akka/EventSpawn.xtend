package com.sirolf2009.muse.akka

import akka.actor.ActorRef
import org.eclipse.xtend.lib.annotations.Data
import scala.Option

@Data class EventSpawn extends Event {
	
	Option<ActorRef> actor
	
}