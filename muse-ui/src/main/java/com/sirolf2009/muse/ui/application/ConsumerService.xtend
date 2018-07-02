package com.sirolf2009.muse.ui.application

import com.sirolf2009.muse.core.MStreamBuilder
import com.sirolf2009.muse.ui.model.StartConsumerEvent
import com.sirolf2009.muse.ui.properties.KafkaStreamsProperties
import java.net.InetAddress
import java.util.Properties
import java.util.concurrent.ExecutorService
import javafx.beans.property.ObjectProperty
import javafx.scene.Node
import javafx.scene.control.Label
import org.apache.kafka.clients.consumer.ConsumerConfig
import org.apache.kafka.clients.consumer.KafkaConsumer
import org.apache.kafka.common.serialization.Serdes

import static com.sirolf2009.muse.core.AvroExtensions.*
import javafx.application.Platform
import com.sirolf2009.muse.core.MKafkaStream

class ConsumerService {

	new(ExecutorService executor, String bootstrapServers, ObjectProperty<Node> objectProperty) {
		val props = new KafkaStreamsProperties() => [
			setApplicationID("MUSE-CONSUMER-SERVICE")
			setClientIDLocalHost()
			setBootstrapServers(bootstrapServers)
			setDefaultKeySerde(Serdes.String())
			setDefaultValueSerde(Serdes.ByteArray())
		]
		val builder = new MStreamBuilder(props)
		val MKafkaStream<String, byte[]> stream = builder.stream("MUSE-START-CONSUMERS")
		stream.mapValues[parse(it, StartConsumerEvent.SCHEMA$) as StartConsumerEvent].mapValues [ event |
			val consumerProps = new Properties() => [
				put(ConsumerConfig.CLIENT_ID_CONFIG, InetAddress.getLocalHost().getHostName())
				put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092")
				put(ConsumerConfig.GROUP_ID_CONFIG, "group")
				put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, event.getKeyDeserializer().toString())
				put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, event.getValueDeserializer().toString())
			]
			val consumer = new KafkaConsumer<Object, Object>(consumerProps)
			val label = new Label()
			Platform.runLater[objectProperty.set(label)]
			consumer.subscribe(#[event.getTopic().toString()])
			executor.submit [
				while(true) {
					consumer.poll(100).forEach[
						Platform.runLater[
							label.textProperty().set((key() -> value()).toString())
						]
					]
				}
			]
			consumer
		]
		val streams = builder.build()
		streams.start()
	}

}
