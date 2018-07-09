package com.sirolf2009.muse.core.model

import com.google.common.graph.ImmutableValueGraph
import com.sirolf2009.muse.core.cells.MuseCell
import com.sirolf2009.muse.core.cells.OperationCell
import io.reactivex.Observable

interface IComponent<T> {
	
	def Observable<T> getLastOutput()
	def ImmutableValueGraph<IComponent<?>, IConnection<?, ?>> getGraph()
	def String getName()
	
	def MuseCell<T> getCell() {
		return new OperationCell(getName(), getLastOutput())
	}
	
}