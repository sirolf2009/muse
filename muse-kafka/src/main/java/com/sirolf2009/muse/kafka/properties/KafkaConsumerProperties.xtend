package com.sirolf2009.muse.kafka.properties

import org.apache.kafka.clients.consumer.ConsumerConfig
import org.apache.kafka.common.serialization.Serde

class KafkaConsumerProperties extends KafkaProperties {
	
	override void setClientID(String clientID) {
		put(ConsumerConfig.CLIENT_ID_CONFIG, clientID)
	}

	def void setGroup(String group) {
		put(ConsumerConfig.GROUP_ID_CONFIG, group)
	}
	
	override void setBootstrapServers(String bootstrapServers) {
		put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers)
	}
	
	def void setKeyDeserializer(Class<?> deserializer) {
		put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, deserializer.getName())
	}
	
	def void setValueDeserializer(Class<?> deserializer) {
		put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, deserializer.getName())
	}
	
	def void setMaxPollRecords(Number amount) {
		put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, amount)
	}
	
	def void setMaxBytes(Number amount) {
		put(ConsumerConfig.FETCH_MAX_BYTES_CONFIG, amount)
	}
	
	def void setMinBytes(Number amount) {
		put(ConsumerConfig.FETCH_MIN_BYTES_CONFIG, amount)
	}
	
	def void enableAutoCommit() {
		setAutoCommitEnabled(true)
	}
	
	def void disableAutoCommit() {
		setAutoCommitEnabled(false)
	}
	
	def void setAutoCommitEnabled(boolean enabled) {
		put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, enabled)
	}
	
	def void setAutoOffsetNone() {
		setAutoOffsetReset("none")
	}
	
	def void setAutoOffsetEarliest() {
		setAutoOffsetReset("earliest")
	}
	
	def void setAutoOffsetLatest() {
		setAutoOffsetReset("latest")
	}
	
	def void setAutoOffsetReset(String autoOffsetReset) {
		put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, autoOffsetReset)
	}
	
	def static apply(String group, String bootstrapServers, Serde<?> keyDeserializer, Serde<?> valueDeserializer) {
		return apply(group, bootstrapServers, keyDeserializer.deserializer().class, valueDeserializer.deserializer().class)
	}
	
	def static apply(String group, String bootstrapServers, Class<?> keyDeserializer, Class<?> valueDeserializer) {
		new KafkaConsumerProperties() => [
			setGroup(group)
			setBootstrapServers(bootstrapServers)
			setKeyDeserializer(keyDeserializer)
			setValueDeserializer(valueDeserializer)
			setClientIDLocalHost()
		]
	}
	
}
