package com.sirolf2009.muse.fxgraph

import com.sirolf2009.muse.interfaces.ISupplier
import javafx.beans.value.ObservableValue

abstract class MuseSupplierCell extends MuseCell {
	
	def ObservableValue<? extends ISupplier<?>> supplierProperty()
	def ISupplier<?> getSupplier() {
		return supplierProperty().getValue()
	}

}