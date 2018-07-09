package com.sirolf2009.muse.core.model

import com.fxgraph.graph.Model
import com.google.common.graph.ImmutableValueGraph
import com.sirolf2009.muse.core.MuseEdge
import com.sirolf2009.muse.core.cells.MuseCell
import java.util.HashMap
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class Blueprint {

	val ImmutableValueGraph<IComponent<?>, IConnection<?, ?>> graph
	val Model model

	new(ITerminal<?> terminal) {
		graph = terminal.getGraph()

		model = new Model()
		val componentToCell = new HashMap<IComponent<?>, MuseCell<?>>()
		graph.nodes().forEach [
			componentToCell.put(it, it.getCell())
			model.addCell(componentToCell.get(it))
		]
		graph.edges().forEach [
			model.addEdge(new MuseEdge(componentToCell.get(source()), componentToCell.get(target())))
		]
		model.endUpdate()
	}

}
