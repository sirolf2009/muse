package com.sirolf2009.muse

import akka.actor.ActorRef
import akka.actor.ActorSystem
import akka.actor.Props
import akka.testkit.TestKit
import com.fxgraph.edges.Edge
import com.fxgraph.graph.Graph
import com.fxgraph.layout.AbegoTreeLayout
import com.sirolf2009.muse.FXGraphActor.AddEdge
import com.sirolf2009.muse.FXGraphActor.AddNode
import com.sirolf2009.muse.FXGraphActor.CursorRequest
import com.sirolf2009.muse.FXGraphActor.CursorResponse
import com.sirolf2009.muse.FXGraphActor.Lock
import com.sirolf2009.muse.FXGraphActor.NavigateTo
import com.sirolf2009.muse.FXGraphActor.Unlock
import com.sirolf2009.muse.actorgraph.ServerCell
import javafx.scene.Scene
import javafx.scene.layout.StackPane
import javafx.stage.Stage
import org.abego.treelayout.Configuration.Location
import org.junit.Assert
import org.junit.Test
import org.testfx.framework.junit.ApplicationTest

class FXGraphActorTest extends ApplicationTest {

	var Graph graph

	override start(Stage stage) throws Exception {
		graph = new Graph()
		stage.setScene(new Scene(new StackPane(graph.getCanvas()), 800, 600))
		stage.show()
	}

	@Test
	def void testLocking() {
		val system = ActorSystem.create()
		val graphActor = system.actorOf(Props.create(FXGraphActor, graph), "graph")
		Thread.sleep(1000)
		
		val cellA = new ServerCell("A")
		graphActor.tell(new AddNode(cellA), ActorRef.noSender())
		Thread.sleep(1000)
		Assert.assertTrue(graph.getModel().getAddedCells().contains(cellA))
		
		graphActor.tell(new Lock(), ActorRef.noSender())
		
		val cellB = new ServerCell("B")
		graphActor.tell(new AddNode(cellB), ActorRef.noSender())
		Thread.sleep(1000)
		Assert.assertFalse(graph.getModel().getAddedCells().contains(cellB))

		val probe = new TestKit(system)
		graphActor.tell(new CursorRequest(), probe.testActor())
		Assert.assertEquals(0, probe.expectMsgClass(CursorResponse).getCursor())
		
		graphActor.tell(new Unlock(), ActorRef.noSender())
		Thread.sleep(1000)
		Assert.assertTrue(graph.getModel().getAllCells().contains(cellB))
	}

	@Test
	def void testCheckHistory() {
		val system = ActorSystem.create()
		val graphActor = system.actorOf(Props.create(FXGraphActor, graph), "graph")
		Thread.sleep(1000)
		val cellA = new ServerCell("A")
		graphActor.tell(new AddNode(cellA), ActorRef.noSender())
		Thread.sleep(1000)
		Assert.assertTrue(graph.getModel().getAddedCells().contains(cellA))
		val cellB = new ServerCell("B")
		graphActor.tell(new AddNode(cellB), ActorRef.noSender())
		Thread.sleep(1000)
		Assert.assertTrue(graph.getModel().getAddedCells().contains(cellB))

		val probe = new TestKit(system)
		graphActor.tell(new CursorRequest(), probe.testActor())
		Assert.assertEquals(2, probe.expectMsgClass(CursorResponse).getCursor())
		
		graphActor.tell(new NavigateTo(1), probe.testActor())
		Thread.sleep(1000)
		graphActor.tell(new CursorRequest(), probe.testActor())
		Assert.assertEquals(1, probe.expectMsgClass(CursorResponse).getCursor())
		
		Assert.assertTrue(graph.getModel().getAllCells().contains(cellA))
		Assert.assertFalse(graph.getModel().getAllCells().contains(cellB))
	}

	@Test
	def void testAddNodesAndEdges() {
		val system = ActorSystem.create()
		val graphActor = system.actorOf(Props.create(FXGraphActor, graph), "graph")
		Thread.sleep(1000)
		val cellA = new ServerCell("A")
		graphActor.tell(new AddNode(cellA), ActorRef.noSender())
		Thread.sleep(1000)
		Assert.assertTrue(graph.getModel().getAddedCells().contains(cellA))
		val cellB = new ServerCell("B")
		graphActor.tell(new AddNode(cellB), ActorRef.noSender())
		Thread.sleep(1000)
		Assert.assertTrue(graph.getModel().getAddedCells().contains(cellB))
		val edge = new Edge(cellA, cellB)
		graphActor.tell(new AddEdge(edge), ActorRef.noSender())
		graph.layout(new AbegoTreeLayout(200, 200, Location.Bottom))
		Thread.sleep(1000)
		Assert.assertTrue(graph.getModel().getAddedEdges().contains(edge))
	}

}
