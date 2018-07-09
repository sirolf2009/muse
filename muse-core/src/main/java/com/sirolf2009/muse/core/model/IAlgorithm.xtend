package com.sirolf2009.muse.core.model

import com.google.common.graph.ImmutableValueGraph
import com.sirolf2009.muse.core.MuseEdge
import com.sirolf2009.muse.core.cells.MuseCell

interface IAlgorithm {
	
	def ImmutableValueGraph<MuseCell<?>, MuseEdge<?, ?>> getModel()
	
}
