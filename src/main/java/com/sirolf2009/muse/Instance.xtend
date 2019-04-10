package com.sirolf2009.muse

import com.sirolf2009.muse.actorgraph.ActorGraph
import com.sirolf2009.muse.messagetable.Messages
import javafx.scene.control.SplitPane
import javafx.scene.control.Tab
import javafx.scene.control.TabPane
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class Instance extends SplitPane {
	
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

		getItems().addAll(mainView, table)
		setDividerPositions(0.6)
	}
	
}