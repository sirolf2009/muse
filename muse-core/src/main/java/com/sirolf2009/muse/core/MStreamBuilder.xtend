package com.sirolf2009.muse.core

import com.fxgraph.graph.Model
import com.sirolf2009.muse.core.cells.ObservableCell
import com.sirolf2009.muse.core.cells.TopicCell
import io.reactivex.Observable
import java.util.HashMap
import java.util.Map
import java.util.Properties
import org.apache.kafka.common.serialization.Serde
import org.apache.kafka.streams.Consumed
import org.apache.kafka.streams.KafkaStreams
import org.apache.kafka.streams.StreamsBuilder
import org.eclipse.xtend.lib.annotations.Accessors

class MStreamBuilder {

	val streamsBuilder = new StreamsBuilder()
	val Map<String, MKafkaStream<?, ?>> registeredTopics = new HashMap()
	@Accessors val Properties properties
	@Accessors val Model model

	new(Properties properties) {
		this.properties = properties
		model = new Model()
	}

	def synchronized <K, V> MKafkaStream<K, V> stream(String topic) {
		if(registeredTopics.containsKey(topic)) {
			return registeredTopics.get(topic) as MKafkaStream<K, V>
		}
		val node = new TopicCell(topic)
		model.addCell(node)
		val stream = new MKafkaStream<K, V>(streamsBuilder.stream(topic), model, node)
		registeredTopics.put(topic, stream)
		return stream
	}

	def synchronized <K, V> MKafkaStream<K, V> stream(String topic, String keySerde, String valueSerde) {
		stream(topic, Class.forName(keySerde).newInstance() as Serde<?>, Class.forName(valueSerde).newInstance() as Serde<?>)
	}

	def synchronized <K, V> MKafkaStream<K, V> stream(String topic, Serde<?> keySerde, Serde<?> valueSerde) {
		if(registeredTopics.containsKey(topic)) {
			return registeredTopics.get(topic) as MKafkaStream<K, V>
		}
		val node = new TopicCell(topic)
		model.addCell(node)
		val MKafkaStream<K, V> stream = new MKafkaStream(streamsBuilder.stream(topic, Consumed.with(keySerde, valueSerde)), model, node)
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

	def synchronized <V> MRXStream<V> stream(String name, Iterable<V> data) {
		val observable = Observable.fromIterable(data)
		val node = new ObservableCell<V>(observable)
		model.addCell(node)
		return new MRXStream(observable, model, node)
	}

	def synchronized build() {
		val topology = streamsBuilder.build()
		return new MStreams(properties, model, topology, new KafkaStreams(topology, properties))
	}

}
