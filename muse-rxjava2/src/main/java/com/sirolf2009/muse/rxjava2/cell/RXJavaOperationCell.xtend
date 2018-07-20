package com.sirolf2009.muse.rxjava2.cell

import com.fxgraph.cells.AbstractCell
import com.fxgraph.graph.Graph
import com.fxgraph.layout.AbegoTreeLayout
import com.sirolf2009.muse.core.cells.MuseCell
import com.sirolf2009.muse.core.model.Blueprint
import io.reactivex.Observable
import java.util.concurrent.atomic.AtomicReference
import javafx.application.Platform
import javafx.scene.control.TitledPane
import javafx.scene.image.ImageView
import javafx.scene.layout.VBox
import org.abego.treelayout.Configuration.Location
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor @Accessors class RXJavaOperationCell<T> extends AbstractCell implements MuseCell<T> {

	val String name
	val Observable<T> lastOutput
	val Observable<Blueprint> internalBlueprint
	val String image

	override getGraphic(Graph graph) {
		return new TitledPane(name, new VBox() => [
			val imageUrl = '''https://raw.github.com/wiki/ReactiveX/RxJava/images/rx-operators/«image».png'''
			try {
				getChildren().add(new ImageView(imageUrl) => [
					fitWidth = 200
					fitHeight = 100
				])
			} catch(Exception e) {
				throw new IllegalArgumentException('''«imageUrl» not valid''', e)
			}
			val blueprint = new AtomicReference<Graph>()
			internalBlueprint.map[new Graph(getModel())].subscribe [ newGraph |
				Platform.runLater [
					if(blueprint.get() !== null) {
						getChildren().remove(blueprint.get().getScrollPane())
					}
					getChildren().add(newGraph.getScrollPane())
					newGraph.layout(new AbegoTreeLayout(100, 100, Location.Top))
					blueprint.set(newGraph)
				]
			]
		]) => [
			setCollapsible(false)
			getStyleClass.add("muse-node")
		]
	}

	override toString() {
		return '''RXJavaOperationCell[«name»: «lastOutput»]'''
	}

}
