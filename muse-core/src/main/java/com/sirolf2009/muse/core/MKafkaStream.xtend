package com.sirolf2009.muse.core

import com.fxgraph.graph.Model
import com.sirolf2009.muse.core.cells.MuseCell
import com.sirolf2009.muse.core.cells.OperationCell
import com.sirolf2009.muse.core.processor.MuseHookProcessor
import java.util.Set
import org.apache.kafka.streams.KeyValue
import org.apache.kafka.streams.kstream.ForeachAction
import org.apache.kafka.streams.kstream.KStream
import org.apache.kafka.streams.kstream.KeyValueMapper
import org.apache.kafka.streams.kstream.Predicate
import org.apache.kafka.streams.kstream.ValueMapper
import org.apache.kafka.streams.kstream.internals.AbstractStream
import org.apache.kafka.streams.kstream.internals.InternalStreamsBuilder
import org.apache.kafka.streams.kstream.internals.KStreamImpl
import org.apache.kafka.streams.processor.internals.InternalTopologyBuilder

class MKafkaStream<K, V> extends KStreamImpl<K, V> {

	val Model model
	val MuseCell<?> predecessor

	new(KStream<K, V> stream, Model model, MuseCell<?> predecessor) {
		super(stream.getBuilder(), stream.getName(), stream.getSourceNodes(), true)
		this.model = model
		this.predecessor = predecessor
	}

	new(InternalStreamsBuilder builder, String name, Set<String> sourceNodes, boolean repartitionRequired, Model model, MuseCell<?> predecessor) {
		super(builder, name, sourceNodes, repartitionRequired)
		this.model = model
		this.predecessor = predecessor
	}

	override <K1, V1> MKafkaStream<K1, V1> flatMap(KeyValueMapper<? super K, ? super V, ? extends Iterable<? extends KeyValue<? extends K1, ? extends V1>>> mapper) {
		return flatMap("flatMap", mapper);
	}
	
	def <K1, V1> MKafkaStream<K1, V1> flatMap(String name, KeyValueMapper<? super K, ? super V, ? extends Iterable<? extends KeyValue<? extends K1, ? extends V1>>> mapper) {
		val node = addHook(name)
		val superStream = super.<K1, V1>flatMap(mapper)
		return new MKafkaStream(builder, superStream.getName(), superStream.getSourceNodes(), superStream.isRepartitionRequired, model, node)
	}

	override <V1> MKafkaStream<K, V1> mapValues(ValueMapper<? super V, ? extends V1> mapper) {
		return mapValues("mapValues", mapper)
	}
	
	override <V1> flatMapValues(ValueMapper<? super V, ? extends Iterable<? extends V1>> mapper) {
		return flatMapValues("flatMapValues", mapper)
	}
	
	def <V1> MKafkaStream<K, V1> flatMapValues(String name, ValueMapper<? super V, ? extends Iterable<? extends V1>> mapper) {
		val node = addHook(name)
		val superStream = super.<V1>flatMapValues(mapper)
		return new MKafkaStream(builder, superStream.getName(), superStream.getSourceNodes(), superStream.isRepartitionRequired, model, node)
	}
	
	def <V1> MKafkaStream<K, V1> mapValues(String name, ValueMapper<? super V, ? extends V1> mapper) {
		val node = addHook(name)
		val superStream = super.<V1>mapValues(mapper)
		return new MKafkaStream(builder, superStream.getName(), superStream.getSourceNodes(), superStream.isRepartitionRequired, model, node)
	}
	
	override foreach(ForeachAction<? super K, ? super V> action) {
		foreach("foreach", action)
	}
	
	def void foreach(String name, ForeachAction<? super K, ? super V> action) {
		addHook(name)
		super.foreach(action)
	}
	
	override MKafkaStream<K, V> filter(Predicate<? super K, ? super V> predicate) {
		return filter("filter", predicate)
	}
	
	def MKafkaStream<K, V> filter(String name, Predicate<? super K, ? super V> predicate) {
		val node = addHook(name)
		val superStream = super.filter(predicate)
		return new MKafkaStream(builder, superStream.getName(), superStream.getSourceNodes(), superStream.isRepartitionRequired, model, node)
	}
	
	def OperationCell<KafkaPair<K, V>> addHook(String name) {
		val hook = new MuseHookProcessor<K, V>()
		builder.internalTopologyBuilder.addProcessor(builder.newProcessorName("MUSE"), [hook], this.getName())
		val node = new OperationCell(name, hook.getLastOutput())
		model.addCell(node)
		model.addEdge(new MuseEdge(predecessor, node))
		return node
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
