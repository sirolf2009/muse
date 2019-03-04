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
import io.reactivex.schedulers.Schedulers
import java.util.concurrent.TimeUnit

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

		for (Node node : graph) {
			node.addAttribute("ui.label", node.getId());
		}

		val connectAlgo = new ConnectAlgorithm()
		connectAlgo.init(graph)
		connectAlgo.compute()

		Thread.sleep(8000)
	}

	protected String styleSheet = '''
	node {
		fill-color: black;
	}
	node.marked {
		fill-color: red;
	}
	edge {
		fill-color: black;
	}
	edge.marked {
		fill-color: red;
		size: 2px;
	}'''

	static class ConnectAlgorithm implements Algorithm {

		var Graph graph

		override init(Graph graph) {
			this.graph = graph
		}

		override compute() {
			graph.<Node>getNodeSet().forEach [
				val source = getAttribute("muse.connectable", IConnectable);
				<Edge>getEachLeavingEdge.forEach [ edge |
					val node = edge.getTargetNode() as Node
					val sink = node.getAttribute("muse.connectable", IConnectable)
					source.getOutputs().get(0).getData().subscribe(sink.getInputs().get(0).getObserver())
					setAttribute("ui.class", "marked")
					source.getOutputs().get(0).getData().observeOn(Schedulers.computation()).doOnNext[
						edge.setAttribute("ui.class", "marked")
					].delay(500, TimeUnit.MILLISECONDS).subscribe [
						edge.setAttribute("ui.class", "")
					]

					source.getOutputs().get(0).getData().subscribe [
						edge.addAttribute("ui.label", toString())
					]
				]
			]
		}

	}
}
