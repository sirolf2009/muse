package com.sirolf2009.muse.core.model

import java.util.function.Function
import java.util.function.Consumer
import java.util.List

interface IProcessable<T> extends IComponent<T> {
	
	def <T2> IProcessable<T2> map(String name, Function<? super T, ? extends T2> mapper)
	def <T2> IProcessable<T2> flatMap(String name, Function<? super T, ? extends IProcessable<T2>> mapper)
	def <R> IProcessable<List<R>> toList(String name)
	def Blueprint forEach(String name, Consumer<T> consumer)
	
}