package com.sirolf2009.muse.kafka.model

import org.eclipse.xtend.lib.annotations.Data

@Data class TopicDescription {
	val String topic
	val int partition
	val long currentOffset
	val long logEndOffset
	val long lag
	val String consumerID
	val String host
	val String clientID
}
