package com.sirolf2009.muse.cell

import com.fxgraph.graph.Graph
import com.sirolf2009.muse.Project
import com.sirolf2009.muse.Publisher
import com.sirolf2009.muse.XtendEditor
import java.io.File
import javafx.beans.property.SimpleStringProperty
import javafx.beans.property.StringProperty
import javafx.geometry.Pos
import javafx.scene.layout.StackPane
import javafx.scene.paint.Color
import javafx.scene.shape.Rectangle
import javafx.collections.FXCollections
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class MuseCodeCell extends MuseCell {
	
	val StringProperty code
	
	new(Project project, MuseCell parent) {
		super(project, parent)
		getWidth().set(400)
		getName().set("NewCell")
		code = new SimpleStringProperty(getDefaultCode())
	}

	override getGraphic(Graph graph) {
		val view = new Rectangle(width.get(), height.get())

		view.setStroke(Color.BLACK)
		view.setFill(Color.WHITE)

		val editor = new XtendEditor(new File(getProject().getInputPath(), getPath()))
		editor.appendText(code.get())
		editor.setTranslateY(10)
		editor.prefWidthProperty().bind(view.widthProperty())

		return new StackPane(view, editor) => [
			x.unbind()
			setLayoutX(x.get())
			x.bind(layoutXProperty())
			y.unbind()
			setLayoutY(y.get())
			y.bind(layoutYProperty())
			this.getWidth().unbind()
			setPrefWidth(this.getWidth().get())
			this.getWidth().bind(prefWidthProperty())
			this.getHeight().unbind()
			setPrefHeight(this.getHeight().get())
			this.getHeight().bind(prefHeightProperty().subtract(10))
			
			editor.prefWidthProperty().bind(widthProperty())
			editor.prefHeightProperty().bind(heightProperty())
			code.bind(editor.textProperty())
			setAlignment(Pos.CENTER)
		]
	}
	
	def String getDefaultCode() {
		val pathElements = getPath().replaceFirst("/", "").split("/")
		val package = (0 ..< pathElements.size() -1).map[pathElements.get(it)].join(".")
		return '''
		package «package»
		
		import «Publisher.getName()»
		import io.reactivex.Observable
		
		class «getName().get()» implements Publisher<Object> {
			
			override get() {
				return Observable.create[]
			}
			
		}'''
	}
	
	override getDepth() {
		return 0
	}
	
	override getChildren() {
		return FXCollections.emptyObservableList()
	}

}
