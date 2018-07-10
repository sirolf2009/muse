package com.sirolf2009.muse.rxjava2

import com.google.common.graph.ImmutableValueGraph
import com.google.common.graph.MutableValueGraph
import com.sirolf2009.muse.core.cells.OperationCell
import com.sirolf2009.muse.core.model.Blueprint
import com.sirolf2009.muse.core.model.Connection
import com.sirolf2009.muse.core.model.IComponent
import com.sirolf2009.muse.core.model.IConnection
import com.sirolf2009.muse.core.model.IStream
import io.reactivex.Observable
import io.reactivex.subjects.PublishSubject
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor @Accessors class RXStream<T> implements IStream<T>, RXProcessable<T> {

	val Observable<T> lastOutput
	val String name
	val MutableValueGraph<IComponent<?>, IConnection<?, ?>> mutableGraph
	val ImmutableValueGraph<IComponent<?>, IConnection<?, ?>> immutableGraph
	val String image
	val PublishSubject<Blueprint> internalBlueprint = PublishSubject.create()

	new(Observable<T> lastOutput, String name, IComponent<?> predecessor, MutableValueGraph<IComponent<?>, IConnection<?, ?>> mutableGraph, String image) {
		this.lastOutput = lastOutput
		this.name = name
		this.mutableGraph = mutableGraph
		mutableGraph.addNode(this)
		mutableGraph.putEdgeValue(predecessor, this, new Connection(predecessor, this))
		this.immutableGraph = ImmutableValueGraph.copyOf(mutableGraph)
		this.image = image
	}

	override getGraph() {
		return immutableGraph
	}

	override getCell() {
//		return new NodeCell(name, lastOutput, new Pane(new ImageView(image) => [
//			fitWidth = 200
//			fitHeight = 100
//		]))
		return new OperationCell(name, lastOutput, getInternalBlueprint())
	}

	override setInternalBlueprint(Blueprint blueprint) {
		internalBlueprint.onNext(blueprint)
	}

}
