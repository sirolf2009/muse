package com.sirolf2009.muse.ui.properties

import java.net.InetAddress
import org.apache.kafka.clients.consumer.ConsumerConfig

class KafkaConsumerProperties extends KafkaProperties {
	
	def void setClientIDLocalHost() {
		setClientID(InetAddress.getLocalHost().getHostName())
	}

	def void setClientID(String clientID) {
		put(ConsumerConfig.CLIENT_ID_CONFIG, clientID)
	}
	
	def void setBootstrapServers(String bootstrapServers) {
		put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers)
	}
	
	def void setKeyDeserializer(Class<?> deserializer) {
		put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, deserializer.getName())
	}
	
	def void setValueDeserializer(Class<?> deserializer) {
		put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, deserializer.getName())
	}
	
}