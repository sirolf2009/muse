package com.sirolf2009.muse.core.model

import com.google.common.graph.ImmutableValueGraph
import com.google.common.graph.MutableValueGraph
import io.reactivex.Observable
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class Terminal<T> implements ITerminal<T> {
	
	val Observable<T> lastOutput
	val ImmutableValueGraph<IComponent<?>, IConnection<?, ?>> graph
	val String name
	
	new(Observable<T> lastOutput, String name, IComponent<?> predecessor, MutableValueGraph<IComponent<?>, IConnection<?, ?>> mutableGraph) {
		this.lastOutput = lastOutput
		this.name = name
		mutableGraph.addNode(this)
		mutableGraph.putEdgeValue(predecessor, this, new Connection(predecessor, this))
		graph = ImmutableValueGraph.copyOf(mutableGraph)
	}
	
}