package com.sirolf2009.muse.rxjava2

import com.google.common.graph.MutableValueGraph
import com.sirolf2009.muse.core.model.Blueprint
import com.sirolf2009.muse.core.model.IComponent
import com.sirolf2009.muse.core.model.IConnection
import com.sirolf2009.muse.core.model.IProcessable
import com.sirolf2009.muse.core.model.Terminal
import java.util.function.Consumer
import java.util.function.Function

interface RXProcessable<T> extends IProcessable<T> {
	
	override <T2> map(String name, Function<? super T, ? extends T2> mapper) {
		val newObservable = lastOutput.map[mapper.apply(it)]
		new RXStream(newObservable, name, this, mutableGraph, "https://raw.github.com/wiki/ReactiveX/RxJava/images/rx-operators/map.png")
	}
	
	override <R> flatMap(String name, Function<? super T, ? extends IComponent<? extends R>> mapper) {
		val newObservable = lastOutput.flatMap[mapper.apply(it).getLastOutput()]
		new RXStream(newObservable, name, this, mutableGraph, "https://raw.github.com/wiki/ReactiveX/RxJava/images/rx-operators/flatMap.png")
	}
	
	override forEach(String name, Consumer<T> consumer) {
		getLastOutput().subscribe [consumer.accept(it)]
		val terminal = new Terminal(getLastOutput(), name, this, mutableGraph)
		return new Blueprint(terminal)
	}
	
	def MutableValueGraph<IComponent<?>, IConnection<?, ?>> getMutableGraph()
	
}