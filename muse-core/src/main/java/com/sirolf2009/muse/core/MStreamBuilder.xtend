package com.sirolf2009.muse.core

import com.sirolf2009.muse.core.model.Graph
import com.sirolf2009.muse.core.model.TopicNode
import java.util.ArrayList
import java.util.HashMap
import java.util.Map
import java.util.Properties
import java.util.UUID
import org.apache.kafka.clients.producer.KafkaProducer
import org.apache.kafka.clients.producer.ProducerRecord
import org.apache.kafka.common.serialization.Serde
import org.apache.kafka.common.serialization.Serdes
import org.apache.kafka.streams.Consumed
import org.apache.kafka.streams.KafkaStreams
import org.apache.kafka.streams.StreamsBuilder
import org.apache.kafka.streams.StreamsConfig
import org.eclipse.xtend.lib.annotations.Accessors

import static com.sirolf2009.muse.core.Constants.GRAPH_QUEUE

import static extension com.sirolf2009.muse.core.AvroExtensions.*

class MStreamBuilder {

	val streamsBuilder = new StreamsBuilder()
	val Map<String, MStream<?, ?>> registeredTopics = new HashMap()
	@Accessors val Properties properties
	@Accessors val Graph graph
	
	new(Properties properties) {
		this.properties = properties
		graph = new Graph(UUID.randomUUID().toString(), properties.get(StreamsConfig.APPLICATION_ID_CONFIG).toString(), new ArrayList(), new ArrayList())
	}

	def synchronized <K, V> MStream<K, V> stream(String topic) {
		if(registeredTopics.containsKey(topic)) {
			return registeredTopics.get(topic) as MStream<K, V>
		}
		val node = new TopicNode(UUID.randomUUID().toString(), topic, topic, properties.get(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG).toString(), properties.get(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG).toString())
		graph.getChildren().add(node)
		val stream = new MStream<K, V>(streamsBuilder.stream(topic), graph, node.getID())
		registeredTopics.put(topic, stream)
		return stream
	}
	
	def synchronized <K, V> MStream<K, V> stream(String topic, String keySerde, String valueSerde) {
		stream(topic, Class.forName(keySerde).newInstance() as Serde<?>, Class.forName(valueSerde).newInstance() as Serde<?>)
	}

	def synchronized <K, V> MStream<K, V> stream(String topic, Serde<?> keySerde, Serde<?> valueSerde) {
		if(registeredTopics.containsKey(topic)) {
			return registeredTopics.get(topic) as MStream<K, V>
		}
		val node = new TopicNode(UUID.randomUUID().toString(), topic, topic, keySerde.deserializer.getClass().getName(), valueSerde.deserializer.getClass().getName())
		graph.getChildren().add(node)
		val MStream<K, V> stream = new MStream(streamsBuilder.stream(topic, Consumed.with(keySerde, valueSerde)), graph, node.getID())
		registeredTopics.put(topic, stream)
		return stream
	}

//	def synchronized <K, V> MStream<K, V> stream(Collection<String> topics, Consumed<K, V> consumed) {
//		val node = new TopicsNode(UUID.randomUUID().toString(), topics.join(", "), topics.map[it as CharSequence].toList(), consumed.)
//		graph.getChildren().add(node)
//		val cell = new MuseCell(UUID.randomUUID(), topics.join(", "))
//		model.addCell(cell)
//		new MStream(streamsBuilder.stream(topics, consumed), model, Optional.of(cell))
//	}
	
//	def synchronized <K, V> MStream<K, V> stream(Pattern topicPattern, Consumed<K, V> consumed) {
//		val cell = new MuseCell(UUID.randomUUID(), topicPattern.toString())
//		model.addCell(cell)
//		new MStream(streamsBuilder.stream(topicPattern, consumed), model, Optional.of(cell))
//	}
	
	def synchronized build() {
		val topology = streamsBuilder.build()
		val producer = new KafkaProducer<String, byte[]>(properties, Serdes.String().serializer(), Serdes.ByteArray().serializer())
		producer.send(new ProducerRecord<String, byte[]>(GRAPH_QUEUE, graph.toBytes())).get()
		producer.close()
		return new MStreams(properties, graph, topology, new KafkaStreams(topology, properties))
	}
	
}
