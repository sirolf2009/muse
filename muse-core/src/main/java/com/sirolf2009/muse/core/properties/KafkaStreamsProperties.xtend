package com.sirolf2009.muse.core.properties

import org.apache.kafka.common.serialization.Serde
import org.apache.kafka.streams.StreamsConfig

class KafkaStreamsProperties extends KafkaProperties {
	
	def void setApplicationID(String applicationID) {
		put(StreamsConfig.APPLICATION_ID_CONFIG, applicationID)
	}
	
	override void setClientID(String clientID) {
		put(StreamsConfig.CLIENT_ID_CONFIG, clientID)
	}
	
	override void setBootstrapServers(String bootstrapServers) {
		put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers)
	}
	
	def void setDefaultKeySerde(Serde<?> serde) {
		put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, serde.getClass().getName())
	}
	
	def void setDefaultValueSerde(Serde<?> serde) {
		put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, serde.getClass().getName())
	}
	
}