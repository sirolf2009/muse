package com.sirolf2009.muse.core.cells

import com.fxgraph.cells.AbstractCell
import com.fxgraph.graph.Graph
import com.sirolf2009.muse.core.KafkaPair
import com.sirolf2009.muse.core.consumer.ObservableConsumer
import io.reactivex.Observable
import javafx.application.Platform
import javafx.collections.FXCollections
import javafx.scene.chart.LineChart
import javafx.scene.chart.NumberAxis
import javafx.scene.chart.XYChart.Data
import javafx.scene.chart.XYChart.Series
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TitledPane
import javafx.scene.layout.VBox
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor @Accessors class ConsumerCell<K, V> extends AbstractCell implements MuseCell<KafkaPair<K, V>> {

	val String topic
	val String group
	val Observable<KafkaPair<K, V>> lastOutput
	val ObservableConsumer<K, V> consumer

	override getGraphic(Graph graph) {
		val xAxis = new NumberAxis() => [
			setForceZeroInRange(false)
			setTickLabelsVisible(false)
		]
		val yAxis = new NumberAxis() => [
			setForceZeroInRange(false)
			setTickLabelsVisible(false)
		]
		val processRateChart = new LineChart<Number, Number>(xAxis, yAxis) => [
			maxHeight = 8
		]
		val metric = consumer.metrics.get(consumer.metrics.keySet().findFirst[name.equals("records-per-request-avg")])
		val processRateSeries = new Series<Number, Number>("Rate", FXCollections.observableArrayList())
		new Thread [
			while(true) {
				Thread.sleep(1000)
				Platform.runLater[
					processRateSeries.getData().add(new Data(System.currentTimeMillis(), metric.metricValue() as Double))
				]
			}
		].start()
		processRateChart.getData().add(processRateSeries)
		return new TitledPane(topic, new VBox(new Label("Group: " + group), new Button("Reset") => [
			setOnAction [
				consumer.addCommand[seekToBeginning(#[])]
			]
		], processRateChart))
	}

}
