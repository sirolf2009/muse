package com.sirolf2009.muse.event

import akka.actor.ActorSystem
import java.io.Serializable
import java.util.Date
import java.util.UUID
import org.eclipse.xtend.lib.annotations.Data
import com.sirolf2009.muse.MuseAppClientActor

@Data class Event implements Serializable {
	
	val UUID connectionID
	val Date date
	
	new(ActorSystem system, Date date) {
		this(MuseAppClientActor.getConnection(system), date)
	}
	
	new(UUID connectionID, Date date) {
		this.connectionID = connectionID
		this.date = date
	}
	
}
