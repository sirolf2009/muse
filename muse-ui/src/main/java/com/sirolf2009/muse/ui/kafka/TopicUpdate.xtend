package com.sirolf2009.muse.ui.kafka

import org.eclipse.xtend.lib.annotations.Data

@Data class TopicUpdate {
	val String topic
	val int partition
	val long newOffset
}