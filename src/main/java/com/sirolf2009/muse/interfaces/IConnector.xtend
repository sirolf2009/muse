package com.sirolf2009.muse.interfaces

import io.reactivex.Observable
import io.reactivex.Observer

/**
 * Something that handles a connection for a IConnectable
 */
interface IConnector<T> {
	
	def IConnectable getConnectable()
	def Observable<T> getData()
	def Observer<T> getObserver()
	
}