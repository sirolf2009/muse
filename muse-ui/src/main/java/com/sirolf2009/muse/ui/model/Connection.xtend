package com.sirolf2009.muse.ui.model

import com.fxgraph.graph.Model
import com.sirolf2009.muse.core.MStreamBuilder
import com.sirolf2009.muse.ui.GraphToModel
import java.util.Properties
import org.eclipse.xtend.lib.annotations.Accessors

import static com.sirolf2009.muse.core.AvroExtensions.*
import static com.sirolf2009.muse.core.Constants.GRAPH_QUEUE
import com.sirolf2009.muse.core.MKafkaStream

class Connection {
	
	val MStreamBuilder builder
	@Accessors val MKafkaStream<String, Model> graphModels
	
	new(Properties properties) {
		builder = new MStreamBuilder(properties)

		val MKafkaStream<String, byte[]> stream = builder.stream(GRAPH_QUEUE)
		val graphs = stream.mapValues("Parse to graph") [toGraph(it)]
		graphModels = graphs.mapValues("Parse to model", new GraphToModel(properties))
		graphModels.print()
		stream.print()
		stream.foreach("foreach") [k,v|
			println(k -> v)
		]
		println(stream+" "+graphModels)
//		.filter("filter topic cells") [k,v| v instanceof MuseTopicCell]
//		.mapValues("map to topic cells") [it as MuseTopicCell]
//		.foreach("subscribe to topics") [k,v| 
//			val props = new Properties(properties) => [
//				put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, v.getKeyDeserializer())
//				put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, v.getValueDeserializer())
//			]
//			new KafkaConsumer(props) => [
//				subscribe(#[v.getTopic()])
//				executor.submit[
//					while(true) {
//						poll(100).forEach[
//							v.onValuesReceived(key(), value())
//						]
//					}
//				]
//			]
//		]
	}
	
	def start() {
		println("start")
		val streams = builder.build()
		streams.start()
	}
	
}