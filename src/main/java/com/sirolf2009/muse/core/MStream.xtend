package com.sirolf2009.muse.core

import com.fxgraph.graph.Cell
import com.fxgraph.graph.Graph
import com.sirolf2009.muse.core.processor.MuseHookProcessor
import io.reactivex.schedulers.Schedulers
import java.util.Optional
import java.util.Set
import javafx.application.Platform
import org.apache.kafka.streams.KeyValue
import org.apache.kafka.streams.kstream.ForeachAction
import org.apache.kafka.streams.kstream.KStream
import org.apache.kafka.streams.kstream.KeyValueMapper
import org.apache.kafka.streams.kstream.ValueMapper
import org.apache.kafka.streams.kstream.internals.AbstractStream
import org.apache.kafka.streams.kstream.internals.InternalStreamsBuilder
import org.apache.kafka.streams.kstream.internals.KStreamImpl
import org.apache.kafka.streams.processor.internals.InternalTopologyBuilder

class MStream<K, V> extends KStreamImpl<K, V> {

	val Graph graph
	val Optional<Cell> predecessor

	new(KStream<K, V> stream, Graph graph, Optional<Cell> predecessor) {
		super(stream.getBuilder(), stream.getName(), stream.getSourceNodes(), true)
		this.graph = graph
		this.predecessor = predecessor
	}

	new(InternalStreamsBuilder builder, String name, Set<String> sourceNodes, boolean repartitionRequired, Graph graph, Optional<Cell> predecessor) {
		super(builder, name, sourceNodes, repartitionRequired)
		this.graph = graph
		this.predecessor = predecessor
	}

	override <K1, V1> flatMap(KeyValueMapper<? super K, ? super V, ? extends Iterable<? extends KeyValue<? extends K1, ? extends V1>>> mapper) {
		val cell = addHook("flatMap")
		val superStream = super.<K1, V1>flatMap(mapper)
		return new MStream(builder, superStream.getName(), superStream.getSourceNodes(), superStream.isRepartitionRequired, graph, Optional.of(cell))
	}

	override <V1> mapValues(ValueMapper<? super V, ? extends V1> mapper) {
		val cell = addHook("mapValues")
		val superStream = super.<V1>mapValues(mapper)
		return new MStream(builder, superStream.getName(), superStream.getSourceNodes(), superStream.isRepartitionRequired, graph, Optional.of(cell))
	}
	
	override foreach(ForeachAction<? super K, ? super V> action) {
		addHook("forEach")
		super.foreach(action)
	}
	
	def addHook(String name) {
		val hook = new MuseHookProcessor<K, V>()
		builder.internalTopologyBuilder.addProcessor(builder.newProcessorName("MUSE"), [hook], this.getName())
		val cell = new TextCell(name)
		graph.getModel().addCell(cell)
		predecessor.ifPresent [
			graph.getModel().addEdge(new MuseEdge(graph, it, cell) => [edge|
				hook.getSubject().map[toString()].observeOn(Schedulers.io).subscribe [value|
					Platform.runLater[
						edge.textProperty().set(value.toString())
					]
				]
			])
		]
		return cell
	}

	def static getInternalTopologyBuilder(InternalStreamsBuilder builder) {
		InternalStreamsBuilder.declaredFields.filter[it.name.equals("internalTopologyBuilder")].map [
			accessible = true
			it
		].get(0).get(builder) as InternalTopologyBuilder
	}

	def static getBuilder(KStream<?, ?> stream) {
		AbstractStream.declaredFields.filter[it.name.equals("builder")].map [
			accessible = true
			it
		].get(0).get(stream) as InternalStreamsBuilder
	}

	def static getName(KStream<?, ?> stream) {
		AbstractStream.declaredFields.filter[it.name.equals("name")].map [
			accessible = true
			it
		].get(0).get(stream) as String
	}

	def static getSourceNodes(KStream<?, ?> stream) {
		AbstractStream.declaredFields.filter[it.name.equals("sourceNodes")].map [
			accessible = true
			it
		].get(0).get(stream) as Set<String>
	}

	def static isRepartitionRequired(KStream<?, ?> stream) {
		KStreamImpl.declaredFields.filter[it.name.equals("repartitionRequired")].map [
			accessible = true
			it
		].get(0).get(stream) as Boolean
	}

}
