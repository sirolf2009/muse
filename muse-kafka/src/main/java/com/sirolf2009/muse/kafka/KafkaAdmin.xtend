package com.sirolf2009.muse.kafka

import com.sirolf2009.muse.kafka.model.TopicDescription
import com.sirolf2009.muse.kafka.model.TopicUpdate
import java.io.File
import java.nio.charset.Charset
import java.text.SimpleDateFormat
import java.time.Duration
import java.util.Date
import java.util.stream.Collectors
import org.apache.commons.io.IOUtils
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

import static extension java.lang.Integer.*
import static extension java.lang.Long.*

@FinalFieldsConstructor class KafkaAdmin {

	val String bootstrapServer
	val File baseDirectory

	def listGroups() {
		command('''bin/kafka-consumer-groups.sh --bootstrap-server «bootstrapServer» --list''').split("\n").toList().stream().filter[!isEmpty()].skip(1).collect(Collectors.toList())
	}

	def listTopics(String group) {
		command('''bin/kafka-consumer-groups.sh --bootstrap-server «bootstrapServer» --group «group» --describe''').split("\n").toList().stream().filter[!isEmpty()].skip(1).map[split(" ").filter[!isEmpty()].toList()].map [
			new TopicDescription(get(0), get(1).parseInt(), get(2).parseLong(), get(3).parseLong(), get(4).parseLong, get(5), get(6), get(7))
		].collect(Collectors.toList())
	}

	def resetTopicToEarliest(String group, String topic) {
		val command = command('''bin/kafka-consumer-groups.sh --bootstrap-server «bootstrapServer» --group «group» --topic «topic» --reset-offsets --to-earliest --execute''')
		try {
			command.split("\n").toList().stream().filter[!isEmpty()].skip(1).map[split(" ").filter[!isEmpty()].toList()].map [
				try {
					new TopicUpdate(get(0), get(1).parseInt(), get(2).parseLong())
				} catch(Exception e) {
					println("Line Output")
					println(it)
					throw e
				}
			].collect(Collectors.toList())
		} catch(Exception e) {
			println("Command Output")
			println(command)
			throw e
		}
	}

	def resetTopicToLatest(String group, String topic) {
		val command = command('''bin/kafka-consumer-groups.sh --bootstrap-server «bootstrapServer» --group «group» --topic «topic» --reset-offsets --to-latest --execute''')
		try {
			command.split("\n").toList().stream().filter[!isEmpty()].skip(1).map[split(" ").filter[!isEmpty()].toList()].map [
				try {
					new TopicUpdate(get(0), get(1).parseInt(), get(2).parseLong())
				} catch(Exception e) {
					println("Line Output")
					println(it)
					throw e
				}
			].collect(Collectors.toList())
		} catch(Exception e) {
			println("Command Output")
			println(command)
			throw e
		}
	}

	def resetTopicShiftBy(String group, String topic, long amount) {
		command('''bin/kafka-consumer-groups.sh --bootstrap-server «bootstrapServer» --group «group» --topic «topic» --reset-offsets --shift-by «amount» --execute''').split("\n").toList().stream().filter[!isEmpty()].skip(1).map[split(" ").filter[!isEmpty()].toList()].map [
			new TopicUpdate(get(0), get(1).parseInt(), get(2).parseLong())
		].collect(Collectors.toList())
	}

	def resetTopicToDatetime(String group, String topic, Date date) {
		command('''bin/kafka-consumer-groups.sh --bootstrap-server «bootstrapServer» --group «group» --topic «topic» --reset-offsets --to-datetime «new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(date)» --execute''').split("\n").toList().stream().filter[!isEmpty()].skip(1).map[split(" ").filter[!isEmpty()].toList()].map [
			new TopicUpdate(get(0), get(1).parseInt(), get(2).parseLong())
		].collect(Collectors.toList())
	}

	def resetTopicByDuration(String group, String topic, Duration duration) {
		command('''bin/kafka-consumer-groups.sh --bootstrap-server «bootstrapServer» --group «group» --topic «topic» --reset-offsets --by-duration «duration» --execute''').split("\n").toList().stream().filter[!isEmpty()].skip(1).map[split(" ").filter[!isEmpty()].toList()].map [
			new TopicUpdate(get(0), get(1).parseInt(), get(2).parseLong())
		].collect(Collectors.toList())
	}

	def String command(String command) {
		val proc = Runtime.getRuntime().exec(baseDirectory.toString() + "/" + command)
		proc.waitFor()
		val output = IOUtils.toString(proc.getInputStream(), Charset.defaultCharset())
		return output
	}

	def static void main(String[] args) {
		println(new KafkaAdmin("localhost:9092", new File("/opt/kafka_2.12-1.1.0")).listGroups())
	}

}
