package com.sirolf2009.muse.standalone.kafka

import akka.actor.ActorSystem
import akka.serialization.Serialization
import akka.serialization.SerializationExtension
import java.util.ArrayList
import java.util.Properties
import org.apache.kafka.clients.producer.KafkaProducer
import org.apache.kafka.clients.producer.ProducerConfig
import org.apache.kafka.clients.producer.ProducerRecord
import org.apache.kafka.common.serialization.ByteArraySerializer
import org.apache.kafka.common.serialization.LongSerializer

class BufferProducer extends KafkaProducer<Long,Byte[]> {
	
	val Serialization serialization
	val String topic
	
	new(ActorSystem system, String topic, Properties properties) {
		this(SerializationExtension.get(system), topic, properties)
	}

	new(Serialization serialization, String topic, Properties properties) {
		super(properties)
		this.serialization = serialization
		this.topic = topic
	}
	
	def send(Object object) {
		send(new ProducerRecord(topic, encode(object)))
	}
	
	def protected encode(Object object) {
		val data = serialization.findSerializerFor(object).toBinary(object)
		val clazz = object.getClass().getName().getBytes()
		val encoded = new ArrayList<Byte>()
		encoded.add(clazz.size().byteValue())
		#[clazz, data].forEach[encoded.addAll(it)]
		encoded
	}

	def static getDefaultProperties(ActorSystem system) {
		new Properties() => [
			put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092")
			put(ProducerConfig.CLIENT_ID_CONFIG, "BufferProducer")
			put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, LongSerializer.getName())
			put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, ByteArraySerializer.getName())
		]
	}

}
