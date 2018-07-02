package com.sirolf2009.muse.ui.properties

import java.net.InetAddress
import org.apache.kafka.clients.producer.ProducerConfig

class KafkaProducerProperties extends KafkaProperties {
	
	def void setClientIDLocalHost() {
		setClientID(InetAddress.getLocalHost().getHostName())
	}

	def void setClientID(String clientID) {
		put(ProducerConfig.CLIENT_ID_CONFIG, clientID)
	}
	
	def void setBootstrapServers(String bootstrapServers) {
		put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers)
	}
	
	def void setKeySerializer(Class<?> serializer) {
		put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, serializer.getName())
	}
	
	def void setValueSerializer(Class<?> serializer) {
		put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, serializer.getName())
	}
	
}