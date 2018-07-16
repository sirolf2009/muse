package com.sirolf2009.muse.kafka.producer

import java.io.ByteArrayOutputStream
import java.util.Properties
import org.apache.avro.io.EncoderFactory
import org.apache.avro.specific.SpecificDatumWriter
import org.apache.kafka.clients.producer.KafkaProducer
import org.apache.kafka.clients.producer.ProducerRecord
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class AvroProducer<K, V> extends KafkaProducer<K, V> {

	new(Properties properties) {
		super(properties)
	}

	def sendAvro(String topic, Object object) {
		send(new ProducerRecord(topic, serializeAvro(object)))
	}

	def static <T> serializeAvro(T object) {
		val writer = new SpecificDatumWriter<T>(object.getClass() as Class<T>)
		val out = new ByteArrayOutputStream()
		val encoder = new EncoderFactory().binaryEncoder(out, null)
		writer.write(object, encoder)
		encoder.flush()
		return out.toByteArray()
	}

}
