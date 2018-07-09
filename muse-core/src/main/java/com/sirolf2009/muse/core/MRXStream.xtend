package com.sirolf2009.muse.core

import com.fxgraph.graph.Model
import com.sirolf2009.muse.core.cells.MuseCell
import com.sirolf2009.muse.core.cells.OperationCell
import io.reactivex.Observable
import io.reactivex.functions.Consumer
import io.reactivex.functions.Function
import com.sirolf2009.muse.core.cells.DisposableCell
import io.reactivex.disposables.Disposable
import io.reactivex.ObservableSource
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class MRXStream<T> {

	val Observable<T> observable
	val Model model
	val MuseCell<?> predecessor

	new(Observable<T> observable, Model model, MuseCell<?> predecessor) {
		this.observable = observable
		this.model = model
		this.predecessor = predecessor
	}
	
	def <R> MRXStream<R> map(String name, Function<T, R> function) {
		val observable = observable.map(function)
		new MRXStream(observable, model, addHook(name, observable))
	}
	
	def <R> MRXStream<R> flatMap(String name, Function<? super T, ? extends ObservableSource<? extends R>> mapper) {
		val observable = observable.flatMap(mapper)
		new MRXStream(observable, model, addHook(name, observable))
	}
	
	def MRXStream<T> concatWith(String name, MRXStream<T> other) {
		val observable = observable.concatWith(other.observable)
		val cell = addHook(name, observable)
		model.addEdge(new MuseEdge(other.predecessor, cell))
		new MRXStream(observable, model, cell)
	}
	
	def Disposable subscribe(String name, Consumer<? super T> consumer) {
		observable.subscribe(consumer) => [
			addHook(name, new DisposableCell(name, it))
		]
	}
	
	def <N> addHook(String name, Observable<N> observable) {
		return addHook(name, new OperationCell<N>(name, observable))
	}
	
	def <N> addHook(String name, MuseCell<N> cell) {
		model.addCell(cell)
		model.addEdge(new MuseEdge(predecessor, cell))
		return cell
	}
	
}