package com.sirolf2009.muse.core

import com.fxgraph.graph.ICell
import com.fxgraph.graph.Model
import com.sirolf2009.muse.core.model.Edge
import com.sirolf2009.muse.core.model.Graph
import com.sirolf2009.muse.core.model.Node
import java.util.HashMap
import java.util.UUID

class ModelToGraph {
	
	def static toGraph(Model model, String applicationName) {
		val idMap = new HashMap()
		val getOrCreateID = [ICell node|
			if(!idMap.containsKey(node)) {
				idMap.put(node, UUID.randomUUID().toString())
			}
			return idMap.get(node)
		]
		val nodes = model.getAllCells().map[new Node(getOrCreateID.apply(it), toString(), getCellChildren().map[getOrCreateID.apply(it) as CharSequence].toList())]
		val edges = model.getAllEdges().map[new Edge(getOrCreateID.apply(getSource()), getOrCreateID.apply(getTarget()))]
		new Graph(UUID.randomUUID().toString(), applicationName, edges, nodes)
	}
	
}