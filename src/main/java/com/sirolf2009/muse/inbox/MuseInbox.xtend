package com.sirolf2009.muse.inbox

import akka.actor.AbstractActor
import akka.actor.ActorRef
import akka.actor.ActorSystem
import akka.actor.Terminated
import akka.^dispatch.MailboxType
import akka.^dispatch.MessageQueue
import akka.^dispatch.ProducesMessageQueue
import akka.^dispatch.RequiresMessageQueue
import akka.^dispatch.UnboundedMailbox
import com.sirolf2009.muse.event.EventKill
import com.sirolf2009.muse.event.EventSpawn
import com.typesafe.config.Config
import java.util.Date
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import scala.Option

class MuseInbox implements MailboxType, ProducesMessageQueue<MuseInboxQueue> {
	
	new(ActorSystem.Settings settings, Config config) {
	}

	override MessageQueue create(Option<ActorRef> owner, Option<ActorSystem> system) {
		if(system.isDefined()) {
			system.get().eventStream().publish(new EventSpawn(system.get(), new Date(), owner))
			system.get().registerOnTermination[
				system.get().eventStream().publish(new EventKill(system.get(), new Date(), owner))
			]
			//FIXME for some reason the DeathWatcher creates a MuseInbox, resulting in a stack overflow
//			system.get().actorOf(Props.create(DeathWatcher, owner.get()), "DeathWatcher")
		}
		return new MuseInboxQueue(owner, system)
	}
	
	@FinalFieldsConstructor static class DeathWatcher extends AbstractActor implements RequiresMessageQueue<UnboundedMailbox> {
		
		val ActorRef actor
		
		override preStart() throws Exception {
			context().watch(actor)
		}
		
		override createReceive() {
			return receiveBuilder().match(Terminated) [
				context().system().eventStream().publish(new EventKill(context().system(), new Date(), Option.apply(actor)))
				context().stop(getSelf())
			].build()
		}
		
	}

}
