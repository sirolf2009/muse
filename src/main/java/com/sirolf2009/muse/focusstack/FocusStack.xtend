package com.sirolf2009.muse.focusstack

import com.sirolf2009.muse.MuseCell
import javafx.beans.binding.Bindings
import javafx.beans.property.SimpleIntegerProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class FocusStack {

	val ObservableList<MuseCell> focusList = FXCollections.observableArrayList()
	val focusIndex = new SimpleIntegerProperty(0)
	val focusedCell = Bindings.createObjectBinding([
		if(focusList.size() > focusIndex.get()) {
			focusList.get(focusIndex.get())
		} else {
			return null
		}
	], focusList, focusIndex)

	def push(MuseCell item) {
		clearAbove()
		focusList.add(item)
		ascend()
	}

	def ascend() {
		if(focusList.size() > focusIndex.get() + 1) {
			focusIndex.set(focusIndex.get() + 1)
		}
	}

	def descend() {
		if(focusIndex.get() > 0) {
			focusIndex.set(focusIndex.get() - 1)
		}
	}

	def clearAbove() {
		focusList.remove(focusIndex.get()+1 ..< focusList.size())
	}

}
