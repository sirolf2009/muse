package com.sirolf2009.muse.standalone.kafka

import akka.actor.ActorSystem
import akka.serialization.Serialization
import akka.serialization.SerializationExtension
import java.time.Duration
import java.util.Properties
import org.apache.kafka.clients.consumer.ConsumerConfig
import org.apache.kafka.clients.consumer.KafkaConsumer
import org.apache.kafka.common.serialization.ByteArraySerializer
import org.apache.kafka.common.serialization.LongSerializer

class BufferConsumer extends KafkaConsumer<Long, Byte[]> {

	val Serialization serialization

	new(ActorSystem system, String topic, Properties properties) {
		this(SerializationExtension.get(system), topic, properties)
	}

	new(Serialization serialization, String topic, Properties properties) {
		super(properties)
		this.serialization = serialization
		subscribe(#[topic])
	}

	def receive() {
		poll(Duration.ofSeconds(1)).map[decode(value())]
	}

	def protected decode(Byte[] encoded) {
		val classLength = encoded.get(0).intValue()
		val type = Class.forName(new String(encoded.subList(1, classLength + 1)))
		val data = encoded.subList(classLength + 1, encoded.size() - 1)
		serialization.deserialize(data, type)
	}

	def static getDefaultProperties(ActorSystem system) {
		new Properties() => [
			put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092")
			put(ConsumerConfig.CLIENT_ID_CONFIG, "BufferConsumer")
			put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, LongSerializer.getName())
			put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, ByteArraySerializer.getName())
		]
	}

}
