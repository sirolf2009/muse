package com.sirolf2009.muse.akka

import akka.actor.AbstractActor
import akka.actor.ActorSystem
import akka.actor.Props
import akka.^dispatch.RequiresMessageQueue

class AkkaTest {
	
	static class TestActor extends AbstractActor implements RequiresMessageQueue<MyMailboxSemantics> {
		
		override createReceive() {
			return receiveBuilder().matchAny[
				println(getSelf()+" "+it)
			].build()
		}
		
	}
	
	def static void main(String[] args) {
		val system = ActorSystem.create("test-system")
		val actor = system.actorOf(Props.create(TestActor), "testActor")
		val actor2 = system.actorOf(Props.create(TestActor), "testActor2")
		system.eventStream().subscribe(actor2, Event)
		//system.actorSelection("/*").tell(new Identify(System.currentTimeMillis()), actor2)
		Thread.sleep(5000)
		while(true) {
			actor.tell("Hello", actor)
		}
	}
	
}