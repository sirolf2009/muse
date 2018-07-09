package com.sirolf2009.muse.core.cells

import com.fxgraph.cells.AbstractCell
import com.fxgraph.graph.Graph
import com.sirolf2009.muse.core.KafkaPair
import com.sirolf2009.muse.core.consumer.ObservableConsumer
import io.reactivex.Observable
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TitledPane
import javafx.scene.layout.VBox
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import javafx.scene.control.ButtonBar

@FinalFieldsConstructor @Accessors class ConsumerCell<K, V> extends AbstractCell implements MuseCell<KafkaPair<K, V>> {

	val String topic
	val String group
	val Observable<KafkaPair<K, V>> lastOutput
	val ObservableConsumer<K, V> consumer

	override getGraphic(Graph graph) {
		val bar = new ButtonBar() => [
			getButtons().add(new Button("Reset") => [
				setOnAction [
					consumer.addCommand[seekToBeginning(#[])]
				]
			])
			getButtons().add(new Button("Restore") => [
				setOnAction [
					consumer.addCommand[seekToEnd(#[])]
				]
			])
		]
		return new TitledPane(topic, new VBox(new Label("Group: " + group), bar))
	}

}
