package com.sirolf2009.muse.kafka.producer

import java.io.ByteArrayOutputStream
import java.util.ArrayList
import java.util.Collections
import java.util.List
import java.util.Properties
import java.util.function.Consumer
import org.apache.avro.io.EncoderFactory
import org.apache.avro.specific.SpecificDatumWriter
import org.apache.kafka.clients.producer.KafkaProducer
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class RunnableProducer<K, V> extends KafkaProducer<K, V> implements Runnable {

	val List<Consumer<? super RunnableProducer<K, V>>> commands

	new(Properties properties) {
		super(properties)
		commands = Collections.synchronizedList(new ArrayList())
	}

	override run() {
		while(true) {
			try {
				commands.forEach[accept(this)]
			} catch(Exception e) {
			}
			try {
				//TODO instead of runnable producer, consume MStream<KafkaPair<K, V>> ?
			} catch(Exception e) {
				e.printStackTrace()
			}
		}
	}

	def addCommand(Consumer<? super KafkaProducer<K, V>> command) {
		commands.add(command)
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
