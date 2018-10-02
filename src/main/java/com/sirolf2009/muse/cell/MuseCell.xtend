package com.sirolf2009.muse.cell

import com.fxgraph.cells.AbstractCell
import com.sirolf2009.muse.Project
import com.sirolf2009.treeviewhierarchy.IHierarchicalData
import javafx.beans.property.SimpleBooleanProperty
import javafx.beans.property.SimpleDoubleProperty
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors abstract class MuseCell extends AbstractCell implements IHierarchicalData<MuseCell> {

	val Project project
	val name = new SimpleStringProperty("new cell")
	val showContents = new SimpleBooleanProperty()
	val parent = new SimpleObjectProperty<MuseCell>()
	val x = new SimpleDoubleProperty(0)
	val y = new SimpleDoubleProperty(0)
	val width = new SimpleDoubleProperty(200)
	val height = new SimpleDoubleProperty(200)

	new(Project project) {
		this.project = project
	}

	new(Project project, MuseCell parent) {
		this.project = project
		this.parent.set(parent)
	}

	def abstract int getDepth()

	def int getLevel() {
		if(parent.get() === null) {
			return 0
		} else {
			return parent.get().getLevel() + 1
		}
	}
	
	def String getPath() {
		if(parent.get() === null) {
			return "/"+getName().get()
		} else {
			return parent.get().getPath()+"/"+getName().get()
		}
	}

	override toString() {
		return '''«name.get()»(«getDepth()», «getLevel()»)'''
	}

}
