package com.sirolf2009.muse.standalone.kafka

import akka.actor.AbstractActor
import akka.actor.ActorSystem
import akka.actor.Props
import akka.^dispatch.Envelope
import akka.serialization.SerializationExtension
import com.sirolf2009.muse.event.EventMessage
import java.util.Date
import org.junit.Assert
import org.junit.Test

class SerDeTest {
	
	@Test
	def void testSerializationDeserialization() {
		val system = ActorSystem.create("serde-test")
		val a = system.actorOf(Props.create(DummyActor), "a")
		val b = system.actorOf(Props.create(DummyActor), "b")
		val msg = new EventMessage(system, new Date(), Envelope.apply("Hello World", a), b, 1)
		val data = BufferProducer.encode(SerializationExtension.get(system), msg)
		val roundtrip = BufferConsumer.decode(SerializationExtension.get(system), data).get() as EventMessage
		Assert.assertEquals(msg, roundtrip)
	}
	
	static class DummyActor extends AbstractActor {
		
		override createReceive() {
			return receiveBuilder().build()
		}
		
	}
	
}