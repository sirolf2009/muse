package com.sirolf2009.muse.core.processor

import com.sirolf2009.muse.core.KafkaPair
import io.reactivex.subjects.BehaviorSubject
import org.apache.kafka.streams.processor.AbstractProcessor
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class MuseHookProcessor<K,V> extends AbstractProcessor<K,V> {
	
	val BehaviorSubject<KafkaPair<K,V>> lastOutput
	
	new() {
		lastOutput = BehaviorSubject.create()
	}
	
	override process(K key, V value) {
		lastOutput.onNext(new KafkaPair<K, V>(key, value))
		context.forward(key, value)
	}
	
}