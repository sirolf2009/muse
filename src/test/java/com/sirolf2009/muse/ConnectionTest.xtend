package com.sirolf2009.muse

import akka.actor.ActorSystem
import akka.actor.Props
import com.sirolf2009.muse.client.ClientScreen
import com.sirolf2009.muse.client.MuseClientActor
import com.typesafe.config.ConfigFactory
import java.util.concurrent.atomic.AtomicReference
import javafx.scene.Scene
import javafx.stage.Stage
import org.junit.Assert
import org.junit.Test
import org.testfx.framework.junit.ApplicationTest

class ConnectionTest extends ApplicationTest {

	var ClientScreen main
	
	override start(Stage stage) throws Exception {
		val system = ActorSystem.create("muse-client-system", ConfigFactory.load("client.conf"))
		MuseInternal.startInternalMuse(system)
		
		main = new ClientScreen()
		system.actorOf(Props.create(MuseClientActor, main), "muse-client")
		
		val scene = new Scene(main, 1024, 768)
		scene.getStylesheets().add("/styles.css")

		stage.setScene(scene)
		stage.show()
	}
	
	@Test
	def void test() {
		new Thread [			
			MuseStandalone.main(#[])
		].start()
		
		Thread.sleep(1000)
		
		val exampleApplication = new AtomicReference()
		new Thread [
			exampleApplication.set(ExampleApplication.setup())
		].start()
		
		Thread.sleep(1000)
		
		clickOn("#connect")
		doubleClickOn("muse-server-system@127.0.0.1:2552")
		doubleClickOn("MuseExampleApp")
		
		Thread.sleep(2000)
		
		clickOn("layout")
		Assert.assertEquals("The connection is displayed in the main screen", 1, main.getConnections().getTabs().size())
		val instance = main.getConnections().getTabs().get(0).getContent() as Instance
		Assert.assertEquals("3 nodes are displayed, user, counter and printer", 3, instance.getGraph().getGraph().getModel().getAllCells().size())
		
		Thread.sleep(100000)
		
		exampleApplication.get().terminate()
		
		Thread.sleep(200000)
		
		Assert.assertEquals("MuseExampleApp is no longer displayed", 0, main.getConnectionTree().getRoot().getChildren().get(0).getChildren().size())
	}
	
}