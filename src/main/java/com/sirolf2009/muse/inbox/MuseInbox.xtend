package com.sirolf2009.muse.inbox

import akka.actor.ActorRef
import akka.actor.ActorSystem
import akka.^dispatch.MailboxType
import akka.^dispatch.MessageQueue
import akka.^dispatch.ProducesMessageQueue
import com.sirolf2009.muse.EventSpawn
import com.typesafe.config.Config
import java.util.Date
import scala.Option

//https://github.com/ouven/akka-visualmailbox/blob/master/collector/src/main/scala/de/aktey/akka/visualmailbox/VisualMailbox.scala
class MuseInbox implements MailboxType, ProducesMessageQueue<MuseInboxQueue> {
	
	new(ActorSystem.Settings settings, Config config) {
		// put your initialization code here
	}

	// The create method is called to create the MessageQueue
	override MessageQueue create(Option<ActorRef> owner, Option<ActorSystem> system) {
		if(system.isDefined()) {
			system.get().eventStream().publish(new EventSpawn(new Date(), owner))
		}
		return new MuseInboxQueue(owner, system)
	}

}
