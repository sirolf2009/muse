package com.sirolf2009.muse.core.consumer

import io.reactivex.subjects.BehaviorSubject
import io.reactivex.subjects.Subject
import java.util.Properties
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class ObservableConsumer<K, V> extends RunnableConsumer<K, V> {

	val Subject<K> keyObservable
	val Subject<V> valueObservable

	new(Properties properties) {
		this(properties, BehaviorSubject.create(), BehaviorSubject.create())
	}

	new(Properties properties, Subject<K> keyObservable, Subject<V> valueObservable) {
		super(properties) [
			keyObservable.onNext(getKey())
			valueObservable.onNext(getValue())
		]
		this.keyObservable = keyObservable
		this.valueObservable = valueObservable
	}

}
