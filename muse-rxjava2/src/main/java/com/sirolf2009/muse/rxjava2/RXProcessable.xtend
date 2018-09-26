package com.sirolf2009.muse.rxjava2

import com.google.common.graph.MutableValueGraph
import com.sirolf2009.muse.core.model.Blueprint
import com.sirolf2009.muse.core.model.IComponent
import com.sirolf2009.muse.core.model.IConnection
import com.sirolf2009.muse.core.model.IProcessable
import com.sirolf2009.muse.core.model.Terminal
import io.reactivex.Observable
import io.reactivex.subjects.PublishSubject
import java.util.function.Consumer
import java.util.function.Function
import java.util.function.Predicate
import com.sirolf2009.muse.core.model.IStorage

interface RXProcessable<T> extends IProcessable<T> {

	override <T2> map(String name, Function<? super T, ? extends T2> mapper) {
		val newObservable = lastOutput.map[mapper.apply(it)]
		new RXStream(newObservable, name, this, mutableGraph, "map")
	}

	override <T2> flatMap(String name, Function<? super T, ? extends IProcessable<T2>> mapper) {
		val subject = PublishSubject.create()
		val newObservable = lastOutput.flatMap [
			val mapped = mapper.apply(it)
			val connectable = mapped.getLastOutput().publish()
			subject.onNext(mapped.forEach("display", []))
			connectable.autoConnect()
		]
		new RXStream(newObservable, name, this, mutableGraph, "flatMap") => [ stream |
			subject.subscribe [
				stream.setInternalBlueprint(it)
			]
		]
	}

	override filter(String name, Predicate<? super T> predicate) {
		val newObservable = lastOutput.filter[predicate.test(it)]
		new RXStream<T>(newObservable, name, this, mutableGraph, "filter") as IProcessable<T>
	}

	override distinct(String name) {
		val newObservable = lastOutput.distinct()
		new RXStream(newObservable, name, this, mutableGraph, "distinct") as IProcessable<T>
	}

	override skip(String name, int count) {
		val newObservable = lastOutput.skip(count)
		new RXStream(newObservable, name, this, mutableGraph, "skip") as IProcessable<T>
	}
	
	override store(String name, IStorage<T> storage) {
		val newObservable = lastOutput.doOnNext[storage.store(it)]
		new RXStream(newObservable, name, this, mutableGraph, "doOnNext.o") as IProcessable<T>
	}

	override <R> toList(String name) {
		val newObservable = lastOutput.toList().flatMapObservable [
			Observable.just(it)
		]
		new RXStream(newObservable, name, this, mutableGraph, "toList.2")
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
