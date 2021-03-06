package com.sirolf2009.muse.inbox

import akka.actor.ActorRef
import akka.actor.ActorSystem
import akka.^dispatch.Envelope
import akka.^dispatch.MessageQueue
import com.sirolf2009.muse.event.Event
import com.sirolf2009.muse.event.EventMessage
import java.util.Date
import java.util.concurrent.ConcurrentLinkedQueue
import scala.Option

class MuseInboxQueue implements MessageQueue, MyMailboxSemantics {

	val queue = new ConcurrentLinkedQueue<Envelope>()

	val Option<ActorSystem> system

	new(Option<ActorRef> owner, Option<ActorSystem> system) {
		this.system = system
	}

	override enqueue(ActorRef receiver, Envelope handle) {
		queue.offer(handle)
		if(!(handle.message() instanceof Event) && !handle.message().getClass().toString().split(" ").get(1).startsWith("akka")) {
			system.get().getEventStream().publish(new EventMessage(system.get(), new Date(), handle, receiver))
		}
	}

	override Envelope dequeue() {
		return queue.poll()
	}

	override numberOfMessages() {
		return queue.size()
	}

	override hasMessages() {
		return !queue.isEmpty()
	}

	override cleanUp(ActorRef owner, MessageQueue deadLetters) {
		for (Envelope handle : queue) {
			deadLetters.enqueue(owner, handle)
		}
	}

}
