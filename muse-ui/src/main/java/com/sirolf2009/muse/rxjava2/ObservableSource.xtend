package com.sirolf2009.muse.rxjava2

import com.google.common.graph.ImmutableValueGraph
import com.google.common.graph.MutableValueGraph
import com.google.common.graph.ValueGraphBuilder
import com.sirolf2009.muse.core.model.IComponent
import com.sirolf2009.muse.core.model.IConnection
import com.sirolf2009.muse.core.model.ISource
import io.reactivex.Observable
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class ObservableSource<T> implements ISource<T>, RXProcessable<T> {
	
	val Observable<T> lastOutput
	val String name
	val MutableValueGraph<IComponent<?>, IConnection<?, ?>> mutableGraph
	val ImmutableValueGraph<IComponent<?>, IConnection<?, ?>> immutableGraph
	
	new(Observable<T> lastOutput, String name) {
		this.lastOutput = lastOutput
		this.name = name
		mutableGraph = ValueGraphBuilder.directed().allowsSelfLoops(false).build()
		mutableGraph.addNode(this)
		immutableGraph = ImmutableValueGraph.copyOf(mutableGraph)
	}
	
	override getGraph() {
		return immutableGraph
	}
	
	override getInternalAlgorithm() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}