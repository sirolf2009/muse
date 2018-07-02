package com.sirolf2009.muse.core

import java.net.InetAddress
import java.util.Properties
import java.util.Random
import org.apache.kafka.clients.consumer.ConsumerConfig
import org.apache.kafka.clients.consumer.KafkaConsumer
import org.apache.kafka.clients.producer.KafkaProducer
import org.apache.kafka.clients.producer.ProducerConfig
import org.apache.kafka.clients.producer.ProducerRecord
import org.apache.kafka.common.serialization.DoubleDeserializer
import org.apache.kafka.common.serialization.DoubleSerializer
import org.apache.kafka.common.serialization.LongDeserializer
import org.apache.kafka.common.serialization.LongSerializer
import org.apache.kafka.common.serialization.Serdes
import org.apache.kafka.streams.StreamsConfig

class StreamTest {

	def static void main(String[] args) {
		producerRandom()
	}

	def static stream() {
		println("stream")
		val props = new Properties() => [
			put(StreamsConfig.APPLICATION_ID_CONFIG, "fucking-cancer")
			put(StreamsConfig.CLIENT_ID_CONFIG, InetAddress.getLocalHost().getHostName())
			put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092")
			put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.Long().getClass().getName());
			put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.Double().getClass().getName());
		]
		val builder = new MStreamBuilder(props)
		val MKafkaStream<Long, Double> stream = builder.stream("prices")
//		stream.selectKey[key, value|value].groupByKey(Serialized.with(Serdes.Double(), Serdes.Double())).count().toStream().to("counts", Produced.with(Serdes.Double(), Serdes.Long()))
		val doubleStream = stream.mapValues[it * 2]
		val quadStream = doubleStream.mapValues[it * 4]
		quadStream.foreach[key, value|println("Quad: " + key -> value +" "+quadStream.class)]
		val streams = builder.build()
		streams.cleanUpAndStart()
	}

	def static consumer() {
		println("consumer")
		val props = new Properties() => [
			put(ConsumerConfig.CLIENT_ID_CONFIG, InetAddress.getLocalHost().getHostName())
			put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092")
			put(ConsumerConfig.GROUP_ID_CONFIG, "group")
			put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, DoubleDeserializer.getName());
			put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, LongDeserializer.getName());
		]
		val consumer = new KafkaConsumer<Double, Long>(props)
		consumer.subscribe(#["counts"])
		while(true) {
			consumer.poll(100).forEach [
				println(key().class + " " + key)
				println(value().class + " " + value)
				println()
			]
		}
	}

	def static producerRandom() {
		println("producer-random")
		val props = new Properties() => [
			put(ProducerConfig.CLIENT_ID_CONFIG, InetAddress.getLocalHost().getHostName())
			put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092")
			put(ProducerConfig.ACKS_CONFIG, "all")
			put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, LongSerializer.getName());
			put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, DoubleSerializer.getName());
		]
		val producer = new KafkaProducer<Long, Double>(props)
		val rnd = new Random()
		while(true) {
			producer.send(new ProducerRecord<Long, Double>("prices", System.currentTimeMillis(), Double.valueOf(rnd.nextInt(100)))).get()
			println("send")
			Thread.sleep(100)
		}
	}

}
