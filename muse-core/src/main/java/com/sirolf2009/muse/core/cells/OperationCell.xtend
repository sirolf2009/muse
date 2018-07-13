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
import java.util.concurrent.atomic.AtomicReference

@FinalFieldsConstructor @Accessors class OperationCell<T> extends AbstractCell implements MuseCell<T> {

	val String name
	val Observable<T> lastOutput
	val Observable<Blueprint> internalBlueprint

	override getGraphic(Graph graph) {
		return new TitledPane(name, new HBox() => [
			val blueprint = new AtomicReference<Graph>()
			internalBlueprint.map[new Graph(getModel())].subscribe [ newGraph |
				if(blueprint.get() !== null) {
					getChildren().remove(blueprint.get().getScrollPane())
				}
				getChildren().add(newGraph.getScrollPane())
				newGraph.layout(new AbegoTreeLayout(100, 100, Location.Top))
				blueprint.set(newGraph)
			]
		])
	}

	override toString() {
		return '''OperationCell[«name»: «lastOutput»]'''
	}

}
