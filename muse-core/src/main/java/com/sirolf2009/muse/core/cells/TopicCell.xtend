package com.sirolf2009.muse.core.cells

import com.fxgraph.cells.AbstractCell
import com.fxgraph.graph.Graph
import com.sirolf2009.muse.core.KafkaAdmin
import io.reactivex.Observable
import java.io.File
import javafx.scene.control.Label
import javafx.scene.control.TitledPane
import javafx.scene.layout.VBox
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor @Accessors class TopicCell<T> extends AbstractCell implements MuseCell<T> {

	val String topic
	val Observable<T> lastOutput
	val String group
	val KafkaAdmin kafkaAdmin

	new(String topic, Observable<T> lastOutput, String group, String bootstrapServer, File baseDir) {
		this(topic, lastOutput, group, new KafkaAdmin(bootstrapServer, baseDir))
	}

	override getGraphic(Graph graph) {
		return new TitledPane(topic, new VBox(new Label("Group: " + group)))
	}

}
