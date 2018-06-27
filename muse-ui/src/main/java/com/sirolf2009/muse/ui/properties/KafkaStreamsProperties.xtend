package com.sirolf2009.muse.ui.properties

import org.apache.kafka.streams.StreamsConfig
import java.net.InetAddress
import org.apache.kafka.common.serialization.Serde

class KafkaStreamsProperties extends KafkaProperties {
	
	def void setApplicationID(String applicationID) {
		put(StreamsConfig.APPLICATION_ID_CONFIG, applicationID)
	}
	
	def void setClientIDLocalHost() {
		setClientID(InetAddress.getLocalHost().getHostName())
	}

	def void setClientID(String clientID) {
		put(StreamsConfig.CLIENT_ID_CONFIG, clientID)
	}
	
	def void setBootstrapServers(String bootstrapServers) {
		put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers)
	}
	
	def void setDefaultKeySerde(Serde<?> serde) {
		put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, serde.getClass().getName())
	}
	
	def void setDefaultValueSerde(Serde<?> serde) {
		put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, serde.getClass().getName())
	}
	
}