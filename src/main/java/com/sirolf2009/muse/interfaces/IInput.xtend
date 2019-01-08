package com.sirolf2009.muse.interfaces

import io.reactivex.Observable

interface IInput<T> {
	
	def void connect(Observable<T> observable)
	def Class<T> getInputType()
	
}