package com.sirolf2009.muse.core.properties

import org.apache.kafka.common.serialization.Serde

class LocalProperties extends KafkaStreamsProperties {

	new(String applicationName) {
		setApplicationID(applicationName)
		setClientIDLocalHost()
		setBootstrapServers("localhost:9092")
	}

	def static withSerdes(String applicationName, Serde<?> keySerde, Serde<?> valueSerde) {
		new LocalProperties(applicationName) => [
			setDefaultKeySerde(keySerde)
			setDefaultValueSerde(valueSerde)
		]
	}

}
