package com.sirolf2009.muse.core

import com.fxgraph.graph.Model
import com.sirolf2009.muse.core.cells.ObservableCell
import com.sirolf2009.muse.core.cells.TopicCell
import com.sirolf2009.muse.core.consumer.ObservableConsumer
import com.sirolf2009.muse.core.processor.MuseHookProcessor
import com.sirolf2009.muse.core.properties.KafkaConsumerProperties
import io.reactivex.Observable
import java.io.File
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Map
import java.util.Properties
import java.util.concurrent.ExecutorService
import org.apache.kafka.common.serialization.Serde
import org.apache.kafka.streams.Consumed
import org.apache.kafka.streams.KafkaStreams
import org.apache.kafka.streams.StreamsBuilder
import org.apache.kafka.streams.StreamsConfig
import org.apache.kafka.streams.kstream.KStream
import org.apache.kafka.streams.processor.ProcessorSupplier
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.concurrent.Executors
import com.sirolf2009.muse.core.cells.ConsumerCell
import org.apache.kafka.clients.consumer.ConsumerConfig

class MStreamBuilder {

	val streamsBuilder = new StreamsBuilder()
	val Map<String, MKafkaStream<?, ?>> registeredTopics = new HashMap()
	@Accessors val Properties properties
	@Accessors val Model model
	val List<Runnable> workers
	val ExecutorService executor

	new(Properties properties) {
		this.properties = properties
		model = new Model()
		workers = new ArrayList()
		executor = Executors.newCachedThreadPool()
	}

	def synchronized <K, V> MRXStream<KafkaPair<K, V>> consume(String topic, KafkaConsumerProperties props) {
		val consumer = new ObservableConsumer(props) => [
			subscribe(#[topic])
		]
		workers.add(consumer)
		val observable = consumer.getKeyObservable.zipWith(consumer.getValueObservable(), [a,b| new KafkaPair(a, b)])
		val node = new ConsumerCell<K, V>(topic, props.get(ConsumerConfig.GROUP_ID_CONFIG) as String, observable, consumer)
		model.addCell(node)
		return new MRXStream(observable, model, node)
	}
	
	def synchronized <K, V> MKafkaStream<K, V> stream(String topic) {
		if(registeredTopics.containsKey(topic)) {
			return registeredTopics.get(topic) as MKafkaStream<K, V>
		}
		return addKafkaHook(topic, streamsBuilder.stream(topic))
	}

	def synchronized <K, V> MKafkaStream<K, V> stream(String topic, String keySerde, String valueSerde) {
		stream(topic, Class.forName(keySerde).newInstance() as Serde<K>, Class.forName(valueSerde).newInstance() as Serde<V>)
	}

	def synchronized <K, V> MKafkaStream<K, V> stream(String topic, Serde<K> keySerde, Serde<V> valueSerde) {
		if(registeredTopics.containsKey(topic)) {
			return registeredTopics.get(topic) as MKafkaStream<K, V>
		}
		return addKafkaHook(topic, streamsBuilder.stream(topic, Consumed.with(keySerde, valueSerde)))
	}
	
	def private <K, V> MKafkaStream<K, V> addKafkaHook(String topic, KStream<K, V> stream) {
		val hook = new MuseHookProcessor<K, V>()
		val node = new TopicCell(topic, hook.getLastOutput(), properties.get(StreamsConfig.CLIENT_ID_CONFIG) as String, properties.get(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG) as String, new File("/opt/kafka_2.12-1.1.0"))
		model.addCell(node)
		stream.process(new ProcessorSupplier<K, V>() {
			override get() {
				return hook
			}
		})
		//TODO register hook
		val MKafkaStream<K, V> mStream = new MKafkaStream(stream, model, node)
		registeredTopics.put(topic, mStream)
		return mStream
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
		return new MStreams(properties, model, topology, new KafkaStreams(topology, properties), workers, executor)
	}

}
