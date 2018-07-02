package com.sirolf2009.muse.core

import com.fxgraph.edges.Edge
import com.fxgraph.graph.ICell
import com.fxgraph.graph.Model
import com.sirolf2009.muse.core.cells.OperationCell
import io.reactivex.Observable
import io.reactivex.functions.Function

class MRXStream<T> {

	val Observable<T> observable
	val Model model
	val ICell predecessor

	new(Observable<T> observable, Model model, ICell predecessor) {
		this.observable = observable
		this.model = model
		this.predecessor = predecessor
	}
	
	def <R> MRXStream<R> map(String name, Function<T, R> function) {
		new MRXStream(observable.map(function), model, addHook(name))
	}
	
	def MRXStream<T> concatWith(String name, MRXStream<T> other) {
		new MRXStream(observable.concatWith(other.observable), model, addHook(name))
	}
	
	def addHook(String name) {
		val node = new OperationCell(name)
		model.addCell(node)
		model.addEdge(new Edge(predecessor, node))
		return node
	}
	
}