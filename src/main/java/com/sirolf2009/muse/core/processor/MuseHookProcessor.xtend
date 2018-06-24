package com.sirolf2009.muse.core.processor

import io.reactivex.subjects.BehaviorSubject
import org.apache.kafka.streams.processor.AbstractProcessor
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class MuseHookProcessor<K,V> extends AbstractProcessor<K,V> {
	
	val BehaviorSubject<Pair<K,V>> subject
	
	new() {
		subject = BehaviorSubject.create()
	}
	
	override process(K key, V value) {
		subject.onNext(key -> value)
		context.forward(key, value)
	}
	
}