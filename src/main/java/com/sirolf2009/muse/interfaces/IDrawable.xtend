package com.sirolf2009.muse.interfaces

import javafx.beans.value.ObservableValue

/**
 * Something that can be drawn on the map
 */
interface IDrawable {
	
	def ObservableValue<Double> xProperty()
	def ObservableValue<Double> yProperty()
	def ObservableValue<Double> widthProperty()
	def ObservableValue<Double> heightProperty()
	
}