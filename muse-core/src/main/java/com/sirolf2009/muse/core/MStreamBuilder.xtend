package com.sirolf2009.muse.core

import com.fxgraph.graph.Graph
import java.util.Collection
import java.util.Optional
import java.util.regex.Pattern
import org.apache.kafka.streams.Consumed
import org.apache.kafka.streams.StreamsBuilder
import org.eclipse.xtend.lib.annotations.Accessors

class MStreamBuilder {

	val streamsBuilder = new StreamsBuilder()
	@Accessors val graph = new Graph()

	def synchronized <K, V> MStream<K, V> stream(String topic) {
		val cell = new TextCell(topic)
		graph.getModel().addCell(cell)
		new MStream(streamsBuilder.stream(topic), graph, Optional.of(cell))
	}

	def synchronized <K, V> MStream<K, V> stream(Collection<String> topics, Consumed<K, V> consumed) {
		val cell = new TextCell(topics.join(", "))
		graph.getModel().addCell(cell)
		new MStream(streamsBuilder.stream(topics, consumed), graph, Optional.of(cell))
	}
	
	def synchronized <K, V> MStream<K, V> stream(Pattern topicPattern, Consumed<K, V> consumed) {
		val cell = new TextCell(topicPattern.toString())
		graph.getModel().addCell(cell)
		new MStream(streamsBuilder.stream(topicPattern, consumed), graph, Optional.of(cell))
	}
	
	def synchronized build() {
		return streamsBuilder.build()
	}
	
}
