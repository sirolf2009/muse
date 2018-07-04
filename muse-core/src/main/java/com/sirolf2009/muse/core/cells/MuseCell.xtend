package com.sirolf2009.muse.core.cells

import com.fxgraph.graph.ICell
import io.reactivex.Observable

interface MuseCell<T> extends ICell {
	
	def Observable<T> getLastOutput()
	
}