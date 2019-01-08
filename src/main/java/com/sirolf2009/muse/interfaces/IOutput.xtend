package com.sirolf2009.muse.interfaces

import io.reactivex.Observable

interface IOutput<T> {
	
	def Observable<T> getOutput()
	def Class<T> getOutputType()
	
}