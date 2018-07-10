package com.sirolf2009.muse.kafka.properties

import java.util.Properties
import java.net.InetAddress

abstract class KafkaProperties extends Properties {
	
	def void setClientIDLocalHost() {
		setClientID(InetAddress.getLocalHost().getHostName())
	}
	def void setClientID(String clientID)
	def void setBootstrapServersLocalHost() {
		setBootstrapServers("localhost:9092")
	}
	def void setBootstrapServers(String bootstrapServers)
	
}