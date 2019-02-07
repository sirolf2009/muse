package com.sirolf2009.muse.interfaces

import javafx.beans.binding.DoubleExpression

/**
 * Something that can be drawn on the map
 */
interface IDrawable {
	
	def DoubleExpression xProperty()
	def DoubleExpression yProperty()
	def DoubleExpression widthProperty()
	def DoubleExpression heightProperty()
	
}