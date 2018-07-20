package com.sirolf2009.muse.kafka.producer

import com.sirolf2009.muse.kafka.KafkaPair
import java.util.Properties
import java.util.function.Consumer
import org.apache.kafka.clients.producer.KafkaProducer
import org.eclipse.xtend.lib.annotations.Accessors
import org.apache.kafka.clients.producer.ProducerRecord

@Accessors class ConsumerProducer<K, V> extends KafkaProducer<K, V> implements Consumer<KafkaPair<K, V>> {

	val String topic

	new(Properties properties, String topic) {
		super(properties)
		this.topic = topic
	}
	
	override accept(KafkaPair<K, V> t) {
		send(new ProducerRecord(topic, t.getKey(), t.getValue()))
	}

}
