package com.sirolf2009.muse.ui

import com.fxgraph.edges.Edge
import com.fxgraph.graph.ICell
import com.fxgraph.graph.Model
import com.sirolf2009.muse.core.model.Graph
import com.sirolf2009.muse.core.model.OperationNode
import com.sirolf2009.muse.core.model.TopicNode
import com.sirolf2009.muse.core.model.TopicsNode
import com.sirolf2009.muse.ui.graph.ConsumerEdge
import com.sirolf2009.muse.ui.graph.MuseOperationCell
import com.sirolf2009.muse.ui.graph.MuseTopicCell
import java.util.HashMap
import java.util.Map
import java.util.Properties
import java.util.UUID
import org.apache.kafka.streams.kstream.ValueMapper
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.apache.kafka.clients.consumer.KafkaConsumer
import org.apache.kafka.clients.consumer.ConsumerConfig

@FinalFieldsConstructor class GraphToModel implements ValueMapper<Graph, Model> {
	
	val Properties properties

	override apply(Graph graph) {
		val model = new Model()
		val Map<CharSequence, ICell> cells = new HashMap()
		graph.getChildren().forEach [
			if(it instanceof OperationNode) {
				val cell = new MuseOperationCell(UUID.fromString(getID().toString()), getName().toString)
				model.addCell(cell)
				cells.put(getID(), cell)
			} else if(it instanceof TopicNode) {
				val cell = new MuseTopicCell(UUID.fromString(getID().toString()), getName().toString, getTopic().toString(), getKeyDeserializer().toString(), getValueDeserializer().toString())
				model.addCell(cell)
				cells.put(getID(), cell)
			} else if(it instanceof TopicsNode) {
				val cell = new MuseTopicCell(UUID.fromString(getID().toString()), getName().toString, getTopics().toString(), getKeyDeserializer().toString(), getValueDeserializer().toString())
				model.addCell(cell)
				cells.put(getID(), cell)
			} else {
				throw new IllegalArgumentException('''Unknown cell type: «getClass()»''')
			}
		]
		graph.getMapping().forEach [
			val source = cells.get(getKey())
			val target = cells.get(getValue())
			if(source instanceof MuseTopicCell) {
				model.addEdge(new ConsumerEdge(source, target, getKafkaConsumer(source)))
			} else if(target instanceof MuseTopicCell) {
				model.addEdge(new ConsumerEdge(source, target, getKafkaConsumer(target)))
			} else {
				model.addEdge(new Edge(source, target))
			}
		]
		model.endUpdate()
		model
	}
	
	def getKafkaConsumer(MuseTopicCell topicCell) {
		return new KafkaConsumer(new Properties(properties) => [
			put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, topicCell.getKeyDeserializer())
			put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, topicCell.getValueDeserializer())
		])
	}

}
