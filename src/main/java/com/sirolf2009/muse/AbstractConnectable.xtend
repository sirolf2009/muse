package com.sirolf2009.muse

import com.sirolf2009.muse.interfaces.IConnectable
import javafx.beans.property.SimpleDoubleProperty

abstract class AbstractConnectable implements IConnectable {
	
	val xProperty = new SimpleDoubleProperty()
	val yProperty = new SimpleDoubleProperty()
	val widthProperty = new SimpleDoubleProperty()
	val heightProperty = new SimpleDoubleProperty()
	
	override xProperty() {
		return xProperty
	}
	
	override yProperty() {
		return yProperty
	}
	
	override widthProperty() {
		return widthProperty
	}
	
	override heightProperty() {
		return heightProperty
	}
	
}