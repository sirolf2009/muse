package com.sirolf2009.muse.rxjava2

import com.google.common.graph.MutableValueGraph
import com.sirolf2009.muse.core.model.Blueprint
import com.sirolf2009.muse.core.model.IComponent
import com.sirolf2009.muse.core.model.IConnection
import com.sirolf2009.muse.core.model.IProcessable
import com.sirolf2009.muse.core.model.Terminal
import java.util.function.Consumer
import java.util.function.Function
import io.reactivex.Observable
import io.reactivex.subjects.PublishSubject

interface RXProcessable<T> extends IProcessable<T> {
	
	override <T2> map(String name, Function<? super T, ? extends T2> mapper) {
		val newObservable = lastOutput.map[mapper.apply(it)]
		new RXStream(newObservable, name, this, mutableGraph, "https://raw.github.com/wiki/ReactiveX/RxJava/images/rx-operators/map.png")
	}
	
	override <T2> mapTo(String name, Function<? super T, ? extends IProcessable<T2>> mapper) {
		val subject = PublishSubject.create()
		val newObservable = lastOutput.flatMap[
			val mapped = mapper.apply(it)
			val connectable = mapped.getLastOutput().publish()
			connectable.subscribe [
				subject.onNext(mapped.forEach("display", []))
			]
			connectable.autoConnect()
		]
		new RXStream(newObservable, name, this, mutableGraph, "https://raw.github.com/wiki/ReactiveX/RxJava/images/rx-operators/map.png") => [stream|
			subject.subscribe [
				stream.setInternalBlueprint(it)
			]
		]
	}
	
	override <R> flatMap(String name, Function<? super T, ? extends IProcessable<? extends R>> mapper) {
		val subject = PublishSubject.create()
		val newObservable = lastOutput.flatMap[
			val mapped = mapper.apply(it)
			val connectable = mapped.getLastOutput().publish()
			connectable.subscribe [
				subject.onNext(mapped.forEach("display", []))
			]
			connectable.autoConnect()
		]
		new RXStream(newObservable, name, this, mutableGraph, "https://raw.github.com/wiki/ReactiveX/RxJava/images/rx-operators/flatMap.png") => [stream|
			subject.subscribe [
				stream.setInternalBlueprint(it)
			]
		]
	}
	
	override <R> toList(String name) {
		val newObservable = lastOutput.toList().flatMapObservable [
			Observable.just(it)
		]
		new RXStream(newObservable, name, this, mutableGraph, "https://raw.github.com/wiki/ReactiveX/RxJava/images/rx-operators/toList.2.png")
	}
	
	override forEach(String name, Consumer<T> consumer) {
		getLastOutput().subscribe [
			consumer.accept(it)
		]
		val terminal = new Terminal(getLastOutput(), name, this, mutableGraph)
		return new Blueprint(terminal)
	}
	
	def MutableValueGraph<IComponent<?>, IConnection<?, ?>> getMutableGraph()
	def void setInternalBlueprint(Blueprint blueprint)
	
}