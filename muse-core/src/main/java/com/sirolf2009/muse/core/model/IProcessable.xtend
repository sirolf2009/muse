package com.sirolf2009.muse.core.model

import java.util.function.Function
import java.util.function.Consumer

interface IProcessable<T> extends IComponent<T> {
	
	def <T2> IStream<T2> map(String name, Function<? super T, ? extends T2> mapper)
	def <R> IStream<R> flatMap(String name, Function<? super T, ? extends IComponent<? extends R>> mapper)
	def Blueprint forEach(String name, Consumer<T> consumer)
	
}