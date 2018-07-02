package com.sirolf2009.muse.core

import com.fxgraph.graph.Model
import java.util.Properties
import org.apache.kafka.streams.KafkaStreams
import org.apache.kafka.streams.Topology
import org.eclipse.xtend.lib.annotations.Data

@Data class MStreams {
	
	val Properties properties
	val Model model
	val Topology topology
	val KafkaStreams kafkaStreams
	
	def start() {
		kafkaStreams.start()
		Runtime.getRuntime().addShutdownHook(new Thread[kafkaStreams.close()])
	}
	
	def cleanUpAndStart() {
		kafkaStreams.cleanUp()
		kafkaStreams.start()
		Runtime.getRuntime().addShutdownHook(new Thread[kafkaStreams.close()])
	}
	
}