package com.sirolf2009.muse.ui.model

import com.sirolf2009.muse.core.MStream
import com.sirolf2009.muse.core.MStreamBuilder
import java.util.Properties

import static com.sirolf2009.muse.core.AvroExtensions.*
import static com.sirolf2009.muse.core.Constants.GRAPH_QUEUE

class Connection {
	
	new(Properties properties) {
		val builder = new MStreamBuilder(properties)

		val MStream<String, byte[]> stream = builder.stream(GRAPH_QUEUE)
		stream.mapValues[toGraph(it)].foreach[key,value|
			println(value)
		]
		val streams = builder.build()
		streams.start()
	}
	
}