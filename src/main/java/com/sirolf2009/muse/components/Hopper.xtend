package com.sirolf2009.muse.components

import javafx.scene.image.ImageView
import com.sirolf2009.muse.Muse
import javafx.scene.effect.Glow
import com.almasb.fxgl.entity.view.EntityView
import javafx.scene.shape.Path
import javafx.scene.shape.MoveTo

class Hopper extends ImageView {
	
	val hoverGlow = new Glow(0.8)
	
	new(Muse muse) {
		super(Muse.getClassLoader().getResource("assets/textures/hopper.png").toString())
//		setOnMouseEntered [
//			setEffect(hoverGlow)
//		]
//		setOnMouseExited [
//			setEffect(null)
//		]
//		setOnDragDetected [
//			val path = new Path()
//			path.getElements().add(new MoveTo() => [
//				xProperty.bind()
//			])
//			muse.getGameScene().addGameView(new EntityView())
//		]
	}
	
}