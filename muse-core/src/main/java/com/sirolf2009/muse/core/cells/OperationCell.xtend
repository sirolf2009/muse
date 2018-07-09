package com.sirolf2009.muse.core.cells

import com.fxgraph.cells.AbstractCell
import com.fxgraph.graph.Graph
import com.fxgraph.layout.AbegoTreeLayout
import com.sirolf2009.muse.core.model.Blueprint
import io.reactivex.Observable
import javafx.scene.control.TitledPane
import javafx.scene.layout.HBox
import org.abego.treelayout.Configuration.Location
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor @Accessors class OperationCell<T> extends AbstractCell implements MuseCell<T> {
	
	val String name
	val Observable<T> lastOutput
	val Observable<Blueprint> internalBlueprint
	
	override getGraphic(Graph graph) {
		return new TitledPane(name, new HBox() => [
			internalBlueprint.map[new Graph(getModel())].subscribe [blueprint|
				val node = blueprint.getScrollPane()
				node.widthProperty.addListener[
					blueprint.layout(new AbegoTreeLayout(0, 0, Location.Top))
				]
				getChildren().add(blueprint.getScrollPane())
			]
		])
	}
	
	override toString() {
		return '''OperationCell[«name»: «lastOutput»]'''
	}
	
}