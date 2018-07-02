package com.sirolf2009.muse.core.cells

import com.fxgraph.cells.AbstractCell
import com.fxgraph.graph.Graph
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import io.reactivex.Observable
import javafx.scene.control.Label

@FinalFieldsConstructor class ObservableCell<V> extends AbstractCell implements MuseCell {
	
	val Observable<V> observable
	
	override getGraphic(Graph graph) {
		return new Label(observable.toString())
	}
	
}