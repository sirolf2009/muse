package com.sirolf2009.muse.fxgraph

import com.fxgraph.graph.Graph
import groovy.lang.GroovyShell
import io.reactivex.Observable
import javafx.beans.property.SimpleStringProperty

class MuseGroovySupplierCell extends MuseSupplierCell {
	
	val sourceCode = new SimpleStringProperty()
	val shell = new GroovyShell()
	
	override getGraphic(Graph graph) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	def eval() {
		return shell.evaluate(sourceCode.get()) as Observable<?> 
	}
	
	override supplierProperty() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}