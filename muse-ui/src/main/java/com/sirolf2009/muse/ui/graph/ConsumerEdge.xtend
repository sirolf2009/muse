package com.sirolf2009.muse.ui.graph

import com.fxgraph.edges.Edge
import com.fxgraph.graph.ICell
import org.apache.kafka.clients.consumer.KafkaConsumer

class ConsumerEdge extends Edge {
	
	new(ICell source, ICell target, KafkaConsumer<Object, Object> consumer) {
		super(source, target)
		new Thread([
			while(true) {
				consumer.poll(100).forEach[k,v|
					textProperty.set((k->v).toString())
				]
			}
		]) =>[
			daemon = true
		]
	}
	
}