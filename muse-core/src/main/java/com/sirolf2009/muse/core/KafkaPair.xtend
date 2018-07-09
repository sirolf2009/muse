package com.sirolf2009.muse.core

import com.google.gson.Gson
import javafx.scene.layout.VBox
import org.eclipse.xtend.lib.annotations.Data
import org.fxmisc.richtext.CodeArea
import org.fxmisc.richtext.LineNumberFactory

@Data class KafkaPair<K, V> implements IGraphic {

	val K key
	val V value

	override getGraphic() {
		val keyGraphic = if(key instanceof IGraphic) {
				key.getGraphic()
			} else {
				new CodeArea() => [
					setParagraphGraphicFactory(LineNumberFactory.get(it))
					wrapText = true
					replaceText(0, 0, new Gson().toJson(key))
					prefHeight = 16
				]
			}
		val valueGraphic = if(value instanceof IGraphic) {
				value.getGraphic()
			} else {
				new CodeArea() => [
					setParagraphGraphicFactory(LineNumberFactory.get(it))
					wrapText = true
					replaceText(0, 0, new Gson().toJson(value))
					prefHeight = 16
				]
			}
		return new VBox(keyGraphic, valueGraphic)
	}

}
