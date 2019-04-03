package com.sirolf2009.muse.standalone.kafka

import akka.actor.ActorSystem
import akka.serialization.Serialization
import akka.serialization.SerializationExtension
import java.time.Duration
import java.util.Properties
import java.util.UUID
import org.apache.kafka.clients.consumer.ConsumerConfig
import org.apache.kafka.clients.consumer.KafkaConsumer
import org.apache.kafka.common.serialization.ByteArrayDeserializer
import org.apache.kafka.common.serialization.LongDeserializer

class BufferConsumer extends KafkaConsumer<Long, byte[]> {

	val Serialization serialization

	new(ActorSystem system, String topic, Properties properties) {
		this(SerializationExtension.get(system), topic, properties)
	}

	new(Serialization serialization, String topic, Properties properties) {
		super(properties)
		this.serialization = serialization
		subscribe(#[topic])
	}

	def pollMessages() {
		poll(Duration.ofSeconds(1)).map[decode(value())]
	}

	def protected decode(byte[] encoded) {
		return decode(serialization, encoded)
	}

	def protected static decode(Serialization serialization, byte[] encoded) {
		val classLength = encoded.get(0).intValue()
		val type = Class.forName(new String(encoded.subList(1, classLength + 1)))
		val data = encoded.subList(classLength + 1, encoded.size())
		serialization.deserialize(data, type)
	}

	def static getDefaultProperties() {
		new Properties() => [
			val ID = UUID.randomUUID()
			put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092")
			put(ConsumerConfig.CLIENT_ID_CONFIG, "BufferConsumer-"+ID)
			put(ConsumerConfig.GROUP_ID_CONFIG, "BufferConsumer-"+ID)
			put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, LongDeserializer.getName())
			put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, ByteArrayDeserializer.getName())
			put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest")
		]
	}

}
