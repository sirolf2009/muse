package com.sirolf2009.muse.core

import org.eclipse.xtend.lib.annotations.Data
import javafx.scene.control.Label
import com.google.gson.Gson
import javafx.scene.layout.VBox

@Data class KafkaPair<K, V> implements IGraphic {
	
	val K key
	val V value
	
	override getGraphic() {
		val keyGraphic = if(key instanceof IGraphic) {
			key.getGraphic()
		} else {
			new Label(new Gson().toJson(key))
		}
		val valueGraphic = if(value instanceof IGraphic) {
			value.getGraphic()
		} else {
			new Label(new Gson().toJson(value))
		}
		return new VBox(keyGraphic, valueGraphic)
	}
	
}