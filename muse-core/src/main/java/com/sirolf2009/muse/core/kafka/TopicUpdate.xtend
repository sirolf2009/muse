package com.sirolf2009.muse.core.kafka

import org.eclipse.xtend.lib.annotations.Data

@Data class TopicUpdate {
	val String topic
	val int partition
	val long newOffset
}