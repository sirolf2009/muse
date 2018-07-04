package com.sirolf2009.muse.core.cells

import com.fxgraph.cells.AbstractCell
import com.fxgraph.graph.Graph
import com.sirolf2009.muse.core.KafkaAdmin
import java.io.File
import javafx.scene.control.Label
import javafx.scene.control.TitledPane
import javafx.scene.layout.VBox
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import javafx.scene.control.Button

@FinalFieldsConstructor class TopicCell extends AbstractCell implements MuseCell {
	
	val String topic
	val String group
	val KafkaAdmin kafkaAdmin
	
	new(String topic, String group, String bootstrapServer, File baseDir) {
		this(topic, group, new KafkaAdmin(bootstrapServer, baseDir))
	}
	
	override getGraphic(Graph graph) {
		return new TitledPane(topic, new VBox(new Label("Group: "+group), new Button("Reset") => [
			setOnAction [
				println(kafkaAdmin.resetTopicToEarliest(group, topic))
			]
		]))
	}
	
}