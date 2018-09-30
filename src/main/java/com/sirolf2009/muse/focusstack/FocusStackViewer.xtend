package com.sirolf2009.muse.focusstack

import javafx.scene.control.Label
import javafx.scene.layout.VBox
import org.tbee.javafx.scene.layout.MigPane
import javafx.collections.ListChangeListener.Change
import com.sirolf2009.muse.MuseCell
import javafx.scene.control.ListView
import javafx.scene.control.ListCell
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

class FocusStackViewer extends VBox {
	
	new(FocusStack focusStack) {
		getChildren().add(new MigPane("", "[][][grow, align right][]") => [
			add(new Label("Index:"))
			add(new Label() => [
				textProperty().bind(focusStack.getFocusIndex().asString())
			])
			add(new Label("Size:"))
			add(new Label() => [
				focusStack.getFocusList().addListener[Change<? extends MuseCell> c|
					setText(String.valueOf(focusStack.getFocusList().size()))
				]
			], "span")
		])
		getChildren().add(new ListView(focusStack.getFocusList()) => [
			setEditable(false)
			focusStack.getFocusedCell().addListener[obs,oldVal,newVal |
				getSelectionModel().select(newVal)
			]
			setCellFactory[new MuseCellCell(focusStack)]
		])
	}
	
	@FinalFieldsConstructor static class MuseCellCell extends ListCell<MuseCell> {
		
		val FocusStack focusStack
		
		override protected updateItem(MuseCell item, boolean empty) {
			super.updateItem(item, empty)
			if(item === null || empty) {
				setText(null)
			} else {
				setText('''«focusStack.getFocusList().indexOf(item)»: «item»''')
			}
		}
		
	}
	
}