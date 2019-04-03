package com.sirolf2009.muse.event

import akka.actor.ActorSystem
import com.sirolf2009.muse.MuseConnect
import java.io.Serializable
import java.util.Date
import java.util.UUID
import org.eclipse.xtend.lib.annotations.Data

@Data class Event implements Serializable {
	
	val UUID connectionID
	val Date date
	
	new(ActorSystem system, Date date) {
		this(MuseConnect.getConnection(system), date)
	}
	
	new(UUID connectionID, Date date) {
		this.connectionID = connectionID
		this.date = date
	}
	
}
