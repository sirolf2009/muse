package com.sirolf2009.muse.core.cells

import com.fxgraph.cells.AbstractCell
import com.fxgraph.graph.Graph
import io.reactivex.Observable
import javafx.scene.control.TitledPane
import javafx.scene.layout.VBox
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import io.reactivex.disposables.Disposable
import javafx.scene.control.Button

@FinalFieldsConstructor @Accessors class DisposableCell<T> extends AbstractCell implements MuseCell<T> {
	
	val String name
	val Disposable disposable
	
	override getGraphic(Graph graph) {
		return new TitledPane(name, new VBox() => [
			new Button("Dispose") => [
				onAction = [
					disposable.dispose()
				]
			]
		])
	}
	
	override toString() {
		return '''DisposableCell[«name»: «disposable»]'''
	}
	
	override getLastOutput() {
		return Observable.empty()
	}
	
}