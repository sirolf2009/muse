package com.sirolf2009.muse.core

import com.fxgraph.graph.Model
import java.util.List
import java.util.Properties
import java.util.concurrent.ExecutorService
import org.apache.kafka.streams.KafkaStreams
import org.apache.kafka.streams.Topology
import org.eclipse.xtend.lib.annotations.Data

@Data class MStreams {
	
	val Properties properties
	val Model model
	val Topology topology
	val KafkaStreams kafkaStreams
	val List<Runnable> workers
	val ExecutorService executor
	
	def cleanUpAndStart() {
		kafkaStreams.cleanUp()
		start()
	}
	
	def start() {
		kafkaStreams.start()
		Runtime.getRuntime().addShutdownHook(new Thread[kafkaStreams.close()])
		workers.forEach[executor.submit(it)]
	}
	
}