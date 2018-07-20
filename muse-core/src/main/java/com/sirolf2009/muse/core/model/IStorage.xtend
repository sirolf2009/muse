package com.sirolf2009.muse.core.model

interface IStorage<T> {
	
	def void store(T t)
	def IProcessable<T> load()
	
}