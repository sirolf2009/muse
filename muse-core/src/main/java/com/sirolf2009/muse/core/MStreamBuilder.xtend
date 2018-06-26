package com.sirolf2009.muse.core

import com.fxgraph.graph.Model
import java.util.Collection
import java.util.Optional
import java.util.Properties
import java.util.UUID
import java.util.regex.Pattern
import org.apache.kafka.clients.producer.KafkaProducer
import org.apache.kafka.clients.producer.ProducerRecord
import org.apache.kafka.common.serialization.Serdes
import org.apache.kafka.streams.Consumed
import org.apache.kafka.streams.KafkaStreams
import org.apache.kafka.streams.StreamsBuilder
import org.apache.kafka.streams.StreamsConfig
import org.eclipse.xtend.lib.annotations.Accessors

import static extension com.sirolf2009.muse.core.AvroExtensions.*
import static extension com.sirolf2009.muse.core.ModelToGraph.*

class MStreamBuilder {

	val Properties properties
	val streamsBuilder = new StreamsBuilder()
	@Accessors val model = new Model()
	
	new(Properties properties) {
		this.properties = properties
	}

	def synchronized <K, V> MStream<K, V> stream(String topic) {
		val cell = new MuseCell(UUID.randomUUID(), topic)
		model.addCell(cell)
		new MStream(streamsBuilder.stream(topic), model, Optional.of(cell))
	}

	def synchronized <K, V> MStream<K, V> stream(Collection<String> topics, Consumed<K, V> consumed) {
		val cell = new MuseCell(UUID.randomUUID(), topics.join(", "))
		model.addCell(cell)
		new MStream(streamsBuilder.stream(topics, consumed), model, Optional.of(cell))
	}
	
	def synchronized <K, V> MStream<K, V> stream(Pattern topicPattern, Consumed<K, V> consumed) {
		val cell = new MuseCell(UUID.randomUUID(), topicPattern.toString())
		model.addCell(cell)
		new MStream(streamsBuilder.stream(topicPattern, consumed), model, Optional.of(cell))
	}
	
	def synchronized build() {
		model.endUpdate()
		val topology = streamsBuilder.build()
		val graph = model.toGraph(properties.get(StreamsConfig.APPLICATION_ID_CONFIG) as String)
		val producer = new KafkaProducer<String, byte[]>(properties, Serdes.String().serializer(), Serdes.ByteArray().serializer())
		producer.send(new ProducerRecord<String, byte[]>("MUSE-APPLICATION-GRAPHS", graph.toBytes())).get()
		producer.close()
		return new MStreams(properties, model, graph, topology, new KafkaStreams(topology, properties))
	}
	
}
