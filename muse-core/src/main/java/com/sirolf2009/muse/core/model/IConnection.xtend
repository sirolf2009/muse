package com.sirolf2009.muse.core.model

interface IConnection<A, B> {
	
	def IComponent<A> getSource()
	def IComponent<B> getTarget()
	
}