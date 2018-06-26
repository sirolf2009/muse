package com.sirolf2009.muse.core

import com.sirolf2009.muse.core.model.Graph
import org.apache.avro.specific.SpecificDatumWriter
import java.io.ByteArrayOutputStream
import org.apache.avro.io.EncoderFactory

class AvroExtensions {
	
	def static toBytes(Graph graph) {
		val writer = new SpecificDatumWriter(Graph.SCHEMA$)
		val out = new ByteArrayOutputStream()
		val encoder = new EncoderFactory().binaryEncoder(out, null)
		writer.write(graph, encoder)
		encoder.flush()
		return out.toByteArray()
	}
	
}