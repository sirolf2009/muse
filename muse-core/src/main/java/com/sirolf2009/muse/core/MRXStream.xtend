package com.sirolf2009.muse.core

import com.fxgraph.graph.Model
import com.sirolf2009.muse.core.cells.MuseCell
import com.sirolf2009.muse.core.cells.OperationCell
import io.reactivex.Observable
import io.reactivex.functions.Consumer
import io.reactivex.functions.Function

class MRXStream<T> {

	val Observable<T> observable
	val Model model
	val MuseCell<?> predecessor

	new(Observable<T> observable, Model model, MuseCell<?> predecessor) {
		this.observable = observable
		this.model = model
		this.predecessor = predecessor
	}
	
	def <R> MRXStream<R> map(String name, Function<T, R> function) {
		new MRXStream(observable.map(function), model, addHook(name))
	}
	
	def MRXStream<T> concatWith(String name, MRXStream<T> other) {
		val cell = addHook(name)
		model.addEdge(new MuseEdge(other.predecessor, cell))
		new MRXStream(observable.concatWith(other.observable), model, cell)
	}
	
	def void subscribe(String name, Consumer<? super T> consumer) {
		addHook(name)
		observable.subscribe(consumer)
	}
	
	def addHook(String name) {
		val node = new OperationCell(name, observable)
		model.addCell(node)
		model.addEdge(new MuseEdge(predecessor, node))
		return node
	}
	
}