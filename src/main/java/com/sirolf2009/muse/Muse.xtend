package com.sirolf2009.muse

import com.almasb.fxgl.app.GameApplication
import com.almasb.fxgl.entity.Entities
import com.almasb.fxgl.input.InputModifier
import com.almasb.fxgl.input.UserAction
import com.almasb.fxgl.settings.GameSettings
import com.sirolf2009.muse.components.HighlightComponent
import javafx.scene.input.MouseButton
import com.sirolf2009.muse.components.CombinableComponent

class Muse extends GameApplication {

	override protected initSettings(GameSettings it) {
		setWidth(600)
		setHeight(800)
		setTitle("Muse")
		setVersion("0.0.1-SNAPSHOT") //TODO get from pom
	}
	
	override protected initGame() {
	}
	
	override protected initInput() {
		val it = getInput()
		addAction(new UserAction("Spawn Code Block") {
			override protected onAction() {
				Entities.builder().at(getMousePositionWorld()).viewFromTextureWithBBox("hopper.png").with(new HighlightComponent(), new CombinableComponent()).buildAndAttach(getGameWorld())
			}
		}, MouseButton.PRIMARY, InputModifier.CTRL)
	}

	def static void main(String[] args) {
		launch(args)
	}

}
