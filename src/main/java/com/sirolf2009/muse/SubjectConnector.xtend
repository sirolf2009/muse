package com.sirolf2009.muse

import com.sirolf2009.muse.interfaces.IConnectable
import com.sirolf2009.muse.interfaces.IConnector
import io.reactivex.subjects.Subject
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor class SubjectConnector<T> implements IConnector<T> {
	
	val IConnectable connectable
	val Subject<T> subject
	
	override getData() {
		return subject
	}
	
	override getObserver() {
		return subject
	}
	
	override getConnectable() {
		return connectable
	}
	
}