package com.sirolf2009.muse.core.cells

import com.fxgraph.cells.AbstractCell
import com.fxgraph.graph.Graph
import io.reactivex.Observable
import javafx.scene.layout.Region
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor @Accessors class NodeCell<T> extends AbstractCell implements MuseCell<T> {
	
	val String name
	val Observable<T> lastOutput
	val Region graphic
	
	override getGraphic(Graph graph) {
		return graphic
	}
	
}