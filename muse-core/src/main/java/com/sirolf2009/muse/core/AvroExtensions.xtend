package com.sirolf2009.muse.core

import com.sirolf2009.muse.core.model.Graph
import org.apache.avro.specific.SpecificDatumWriter
import java.io.ByteArrayOutputStream
import org.apache.avro.io.EncoderFactory
import org.apache.avro.specific.SpecificDatumReader
import java.io.ByteArrayInputStream
import org.apache.avro.io.DecoderFactory
import org.apache.avro.Schema

class AvroExtensions {
	
	def static toBytes(Graph graph) {
		val writer = new SpecificDatumWriter(Graph.SCHEMA$)
		val out = new ByteArrayOutputStream()
		val encoder = new EncoderFactory().binaryEncoder(out, null)
		writer.write(graph, encoder)
		encoder.flush()
		return out.toByteArray()
	}
	
	def static toGraph(byte[] bytes) {
		val reader = new SpecificDatumReader(Graph.SCHEMA$)
		val in = new ByteArrayInputStream(bytes)
		val decoder = new DecoderFactory().binaryDecoder(in, null)
		return reader.read(null, decoder) as Graph
	}
	
	def static parse(byte[] bytes, Schema schema) {
		val reader = new SpecificDatumReader(schema)
		val in = new ByteArrayInputStream(bytes)
		val decoder = new DecoderFactory().binaryDecoder(in, null)
		return reader.read(null, decoder)
	}
	
	def static toBytes(Object object, Schema schema) {
		val writer = new SpecificDatumWriter(schema)
		val out = new ByteArrayOutputStream()
		val encoder = new EncoderFactory().binaryEncoder(out, null)
		writer.write(object, encoder)
		encoder.flush()
		return out.toByteArray()
	}
	
}