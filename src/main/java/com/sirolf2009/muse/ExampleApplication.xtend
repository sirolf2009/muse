package com.sirolf2009.muse

import akka.actor.AbstractActor
import akka.actor.ActorSystem
import akka.actor.Props
import akka.event.Logging
import com.sirolf2009.muse.actorgraph.IGraphic
import com.typesafe.config.ConfigFactory
import java.io.Serializable
import java.time.Duration
import java.util.Random
import java.util.UUID
import javafx.scene.control.Label
import javafx.scene.control.TitledPane
import org.eclipse.xtend.lib.annotations.Data

class ExampleApplication {

	def static void main(String[] args) {
		val system = ActorSystem.create("MuseExampleApp", ConfigFactory.load("example-application.conf"))

		if(System.getenv("MUSE_LOCAL") !== null) {// Start an internal muse
			MuseInternal.startInternalMuse(system)
		} else { //Or connect to a muse server
			MuseConnect.connect(system)
		}

		val printer = system.actorOf(Props.create(Printer), "Printer")
		val counter = system.actorOf(Props.create(Counter), "Counter")

		val rand = new Random()
		system.scheduler().schedule(Duration.ofSeconds(1), Duration.ofSeconds(1), [counter.tell(rand.nextInt(10) - 5, counter)], system.dispatcher())

		new Thread [
			while(true) {
				Thread.sleep(rand.nextInt(9_000) + 1000)
				counter.tell(new CountRequest(UUID.randomUUID()), printer)
			}
		].start()
	}

	static class Counter extends AbstractActor {

		var int count

		override createReceive() {
			return receiveBuilder().match(Integer) [
				count += it
			].match(CountRequest) [
				getSender().tell(new CountResponse(requestID, count), getSelf())
			].build()
		}

	}

	@Data static class CountRequest implements Serializable, IGraphic {
		UUID requestID

		override getNode() {
			return new TitledPane(requestID.toString(), new Label("?"))
		}

	}

	@Data static class CountResponse implements Serializable, IGraphic {
		UUID requestID
		int count

		override getNode() {
			return new TitledPane(requestID.toString(), new Label(String.valueOf(count))) => [
				setPrefWidth(100)
			]
		}
	}

	static class Printer extends AbstractActor {

		val log = Logging.getLogger(getContext().getSystem(), this)

		override createReceive() {
			return receiveBuilder().match(CountResponse) [
				log.info("count {}", count)
			].build()
		}

	}

}
