package com.sirolf2009.muse

import akka.actor.AbstractActor
import akka.actor.ActorRef
import akka.actor.ActorSystem
import akka.actor.Props
import com.sirolf2009.muse.event.EventKill
import com.sirolf2009.muse.event.EventMessage
import com.sirolf2009.muse.event.EventSpawn
import javafx.scene.Scene
import javafx.stage.Stage
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor class InternalInstanceActor extends AbstractActor {
	
	val Instance instance
	var ActorRef instanceActor
	
	override preStart() throws Exception {
		instanceActor = context().actorOf(Props.create(InstanceActor, instance), "instance")
	}
	
	override createReceive() {
		return receiveBuilder().match(EventMessage) [
			if(!getEnvelope().sender().isInternalMessage()) {
				instanceActor.tell(it, sender())
			}
		].match(EventSpawn) [
			if(!getActor().get().isInternalMessage()) {
				instanceActor.tell(it, sender())
			}
		].match(EventKill) [
			if(getActor().get().isInternalMessage()) {
				instanceActor.tell(it, sender())
			}
		].matchAny[
			instanceActor.tell(it, sender())
		].build()
	}
	
	def isInternalMessage(ActorRef ref) {
		return ref.path().toString().startsWith(getSelf().path().toString())
	}
	
	def static startInternalMuse(ActorSystem system) {
		val instance = new Instance()
		val instanceActor = system.actorOf(Props.create(InternalInstanceActor, instance), "muse-debug")
		new Stage() => [
			setScene(new Scene(instance) => [
				getStylesheets().add("/styles.css")
			])
			show()
		]
		MuseConnect.connect(system, instanceActor)
	}
	
}