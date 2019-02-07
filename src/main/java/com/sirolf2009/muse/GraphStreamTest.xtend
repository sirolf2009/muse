package com.sirolf2009.muse

import com.sirolf2009.muse.interfaces.DeleteMe.SimpleConsumer
import com.sirolf2009.muse.interfaces.DeleteMe.SimpleConverter
import com.sirolf2009.muse.interfaces.DeleteMe.SimpleSupplier
import com.sirolf2009.muse.interfaces.IConnectable
import org.graphstream.algorithm.Algorithm
import org.graphstream.graph.Edge
import org.graphstream.graph.Graph
import org.graphstream.graph.Node
import org.graphstream.graph.implementations.SingleGraph

class GraphStreamTest {
	
	def static void main(String[] args) {
		new GraphStreamTest();
	}

	new() {
		val graph = new SingleGraph("tutorial 1")

		graph.addAttribute("ui.stylesheet", styleSheet)
		graph.setAutoCreate(true)
		graph.setStrict(false)
		graph.display()

		graph.addEdge("SC", "SimpleSupplier", "SimpleConverter", true)
		graph.addEdge("CC", "SimpleConverter", "SimpleConsumer", true)
		
		graph.getNode("SimpleSupplier").addAttribute("muse.connectable", new SimpleSupplier())
		graph.getNode("SimpleConverter").addAttribute("muse.connectable", new SimpleConverter())
		graph.getNode("SimpleConsumer").addAttribute("muse.connectable", new SimpleConsumer())
		
		
		println("### Simple Supplier ###")
		graph.getNode("SimpleSupplier") => [
			getEachEnteringEdge().forEach[println('''Entering «it»''')]
			getEachLeavingEdge().forEach[println('''Leaving «it»''')]
		]
		println()
		println("### Simple Converter ###")
		graph.getNode("SimpleConverter") => [
			getEachEnteringEdge().forEach[println('''Entering «it»''')]
			getEachLeavingEdge().forEach[println('''Leaving «it»''')]
		]
		println()

		for (Node node : graph) {
			node.addAttribute("ui.label", node.getId());
		}
		
		val connectAlgo = new ConnectAlgorithm()
		connectAlgo.init(graph)
		connectAlgo.compute()
		
		Thread.sleep(8000)
	}

	protected String styleSheet = "node {" + "	fill-color: black;" + "}" + "node.marked {" + "	fill-color: red;" +
		"}";
		
		
	static class ConnectAlgorithm implements Algorithm {
		
		var Graph graph
		
		override init(Graph graph) {
			this.graph = graph
		}
		
		override compute() {
			graph.<Node>getNodeSet().forEach[
				println("Processing node "+it);
				val source = getAttribute("muse.connectable", IConnectable);
				<Edge>getEachLeavingEdge.map[
					getTargetNode() as Node
				].forEach[node|
					val sink = node.getAttribute("muse.connectable", IConnectable)
					println('''Connecting «sink» to «source»''')
					source.getOutputs().get(0).getData().subscribe(sink.getInputs().get(0).getObserver())
					setAttribute("ui.class", "marked")
					node.setAttribute("ui.class", "marked")
				]
			]
		}		
		
	}
}