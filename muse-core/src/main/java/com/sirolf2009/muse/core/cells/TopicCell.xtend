package com.sirolf2009.muse.core.cells

import com.fxgraph.cells.AbstractCell
import com.fxgraph.graph.Graph
import com.sirolf2009.muse.core.KafkaAdmin
import io.reactivex.Observable
import java.io.File
import java.lang.management.ManagementFactory
import java.util.concurrent.TimeUnit
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
import javax.management.ObjectName
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
		val processRateSeries = new Series("Rate", FXCollections.observableArrayList())
		processRateChart.getData().add(processRateSeries)
		val server = ManagementFactory.getPlatformMBeanServer()
			val objectName = new ObjectName('''kafka.streams:type=stream-metrics,client-id=«group»-StreamThread-1''')
			Observable.interval(1, TimeUnit.SECONDS).map[server.getAttribute(objectName, "process-rate") as Double].forEach [ value |
				Platform.runLater [
					processRateSeries.getData().add(new Data<Number, Number>(System.currentTimeMillis(), value))
				]
			]
		return new TitledPane(topic, new VBox(new Label("Group: " + group), new Button("Reset") => [
			setOnAction [
				println(kafkaAdmin.resetTopicToEarliest(group, topic))
			]
		], processRateChart))
	}

}
