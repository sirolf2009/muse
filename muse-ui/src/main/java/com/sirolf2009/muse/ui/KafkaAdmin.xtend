package com.sirolf2009.muse.ui

import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.apache.commons.io.IOUtils
import java.nio.charset.Charset
import com.sirolf2009.muse.ui.kafka.TopicDescription

import static extension java.lang.Integer.*
import static extension java.lang.Long.*
import java.util.stream.Collectors
import java.time.Duration
import com.sirolf2009.muse.ui.kafka.TopicUpdate

@FinalFieldsConstructor class KafkaAdmin {

	val String bootstrapServer
	val File baseDirectory

	/**
	 * Note: This will not show information about old Zookeeper-based consumers.

	 * TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID                                     HOST            CLIENT-ID
	 * counts          0          0               0               0               workstation-e9f920d2-f3f6-4953-8185-7850e6c255ad /127.0.0.1      workstation
	 *  
	 */
	def listTopics(String group) {
		command('''bin/kafka-consumer-groups.sh --bootstrap-server «bootstrapServer» --group «group» --describe''').split("\n").toList().stream().filter[!isEmpty()].skip(1).map[split(" ").filter[!isEmpty()].toList()].map [
			new TopicDescription(get(0), get(1).parseInt(), get(2).parseLong(), get(3).parseLong(), get(4).parseLong, get(5), get(6), get(7))
		].collect(Collectors.toList())
	}

	def resetTopicToEarliest(String group, String topic) {
		command('''bin/kafka-consumer-groups.sh --bootstrap-server «bootstrapServer» --group «group» --topic «topic» --reset-offsets --to-earliest --execute''').split("\n").toList().stream().filter[!isEmpty()].skip(1).map[split(" ").filter[!isEmpty()].toList()].map [
			new TopicUpdate(get(0), get(1).parseInt(), get(2).parseLong())
		].collect(Collectors.toList())
	}

	def resetTopicToLatest(String group, String topic) {
		command('''bin/kafka-consumer-groups.sh --bootstrap-server «bootstrapServer» --group «group» --topic «topic» --reset-offsets --to-latest --execute''').split("\n").toList().stream().filter[!isEmpty()].skip(1).map[split(" ").filter[!isEmpty()].toList()].map [
			new TopicUpdate(get(0), get(1).parseInt(), get(2).parseLong())
		].collect(Collectors.toList())
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
		val proc = Runtime.getRuntime().exec(baseDirectory.toString()+"/"+command)
		proc.waitFor()
		val output = IOUtils.toString(proc.getInputStream(), Charset.defaultCharset())
		return output
	}
	
	def static void main(String[] args) {
		println(new KafkaAdmin("localhost:9092", new File("/opt/kafka_2.12-1.1.0")).resetTopicByDuration("group", "counts", Duration.ofHours(1)))
	}

}
