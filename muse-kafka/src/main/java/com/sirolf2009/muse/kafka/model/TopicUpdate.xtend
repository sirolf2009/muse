package com.sirolf2009.muse.kafka.model

import org.eclipse.xtend.lib.annotations.Data

@Data class TopicUpdate {
	val String topic
	val int partition
	val long newOffset
}