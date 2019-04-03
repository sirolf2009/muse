package com.sirolf2009.muse.standalone.kafka

import akka.actor.AbstractActor
import akka.actor.ActorRef
import akka.actor.ActorSystem
import com.sirolf2009.muse.Event
import com.sirolf2009.muse.EventSpawn
import com.sirolf2009.muse.MuseStandalone.Connect
import com.sirolf2009.muse.MuseStandalone.Disconnect
import com.sirolf2009.muse.event.EventKill
import java.util.ArrayList
import java.util.HashMap
import java.util.concurrent.atomic.AtomicBoolean

class KafkaBufferActor extends AbstractActor {

	val spawns = new ArrayList<EventSpawn>()
	val connections = new HashMap<ActorRef, ConsumerThread>()
	val BufferProducer producer
	val ActorSystem system
	val String topicName

	new(ActorSystem system, String topicName) {
		producer = new BufferProducer(system, topicName, BufferProducer.getDefaultProperties())
		this.system = system
		this.topicName = topicName
	}
	
	override postStop() throws Exception {
		connections.values().forEach[stopConsumer()]
	}

	override createReceive() {
		return receiveBuilder().match(Event) [
			if(!(it instanceof EventSpawn)) {
				producer.send(it)
			}
			if(it instanceof EventSpawn) {
				spawns.add(it)
			} else if(it instanceof EventKill) {
				spawns.remove(spawns.findFirst[spawn|spawn.actor.equals(actor)])
			}
		].match(Connect) [
			spawns.forEach[msg|actor.tell(msg, getSelf())]
			val consumer = new BufferConsumer(system, topicName, BufferConsumer.getDefaultProperties())
			val consumerThread = new ConsumerThread(consumer, actor, getSelf())
			connections.put(actor, consumerThread)
			consumerThread.start()
		].match(Disconnect) [
			connections.get(actor).stopConsumer()
			connections.remove(actor)
		].build()
	}
	
	static class ConsumerThread extends Thread {
		
		val AtomicBoolean running
		
		new(BufferConsumer consumer, ActorRef actor, ActorRef buffer) {
			this(consumer, actor, buffer, new AtomicBoolean(true))
		}
		
		new(BufferConsumer consumer, ActorRef actor, ActorRef buffer, AtomicBoolean running) {
			super [
				while(running.get()) {
					consumer.pollMessages().map[get()].forEach[msg|
						actor.tell(msg, buffer)
					]
				}
			]
			setDaemon(true)
			this.running = running
		}
		
		def stopConsumer() {
			running.set(false)
		}
		
	}

}
