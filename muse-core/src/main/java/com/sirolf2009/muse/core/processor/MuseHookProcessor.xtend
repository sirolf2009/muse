package com.sirolf2009.muse.core.processor

import org.apache.kafka.streams.processor.AbstractProcessor
import org.eclipse.xtend.lib.annotations.Accessors
import javafx.beans.property.ObjectProperty
import javafx.beans.property.SimpleObjectProperty

@Accessors class MuseHookProcessor<K,V> extends AbstractProcessor<K,V> {
	
	val ObjectProperty<Pair<K,V>> message
	
	new() {
		message = new SimpleObjectProperty()
	}
	
	override process(K key, V value) {
		message.set(key -> value)
		context.forward(key, value)
	}
	
}