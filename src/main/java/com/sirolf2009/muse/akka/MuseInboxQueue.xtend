package com.sirolf2009.muse.akka

import akka.actor.ActorRef
import akka.actor.ActorSystem
import akka.^dispatch.Envelope
import akka.^dispatch.MessageQueue
import java.util.Date
import java.util.concurrent.ConcurrentLinkedQueue
import scala.Option

class MuseInboxQueue implements MessageQueue, MyMailboxSemantics {

	val queue = new ConcurrentLinkedQueue<Envelope>()

	val Option<ActorSystem> system

	new(Option<ActorRef> owner, Option<ActorSystem> system) {
		this.system = system
	}

	// these must be implemented; queue used as example
	override enqueue(ActorRef receiver, Envelope handle) {
		queue.offer(handle)
		if(handle.message() instanceof EventMessage) {
			system.get().getEventStream().publish(new EventMessage(new Date(), handle))
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
