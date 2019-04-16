package com.sirolf2009.muse

import com.sirolf2009.muse.actorgraph.ActorGraph
import com.sirolf2009.muse.messagetable.Messages
import javafx.scene.control.Tab
import javafx.scene.control.TabPane
import javafx.scene.layout.StackPane
import org.eclipse.xtend.lib.annotations.Accessors
import javafx.scene.control.SplitPane

@Accessors class Instance extends StackPane {

	val TabPane mainView
	val ActorGraph graph
	val Messages table

	new() {
		getStyleClass().add("map-background")

		mainView = new TabPane()
		graph = new ActorGraph()
		mainView.getTabs().add(new Tab("Actor Graph", graph) => [
			setClosable(false)
		])
		table = new Messages()

		val splitPane = new SplitPane(mainView, table)
		splitPane.setDividerPositions(0.6)
		getChildren().add(splitPane)
	}

}
