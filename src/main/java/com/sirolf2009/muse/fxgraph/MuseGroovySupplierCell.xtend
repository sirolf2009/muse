package com.sirolf2009.muse.fxgraph

import com.fxgraph.graph.Graph
import com.sirolf2009.muse.interfaces.ISupplier
import groovy.lang.GroovyShell
import io.reactivex.Observable
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.beans.value.ObservableValue

class MuseGroovySupplierCell extends MuseSupplierCell {
	
	val ObservableValue<? extends ISupplier<?>> supplierProperty = new SimpleObjectProperty()
	
	val sourceCode = new SimpleStringProperty()
	val shell = new GroovyShell()
	
	override getGraphic(Graph graph) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	def eval() {
		return shell.evaluate(sourceCode.get()) as Observable<?> 
	}
	
	override supplierProperty() {
		supplierProperty
	}
	
}