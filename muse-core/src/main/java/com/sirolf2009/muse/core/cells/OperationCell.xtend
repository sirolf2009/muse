package com.sirolf2009.muse.core.cells

import com.fxgraph.cells.AbstractCell
import com.fxgraph.graph.Graph
import javafx.scene.control.Label
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor class OperationCell extends AbstractCell implements MuseCell {
	
	val String name
	
	override getGraphic(Graph graph) {
		return new Label(name)
	}
	
}