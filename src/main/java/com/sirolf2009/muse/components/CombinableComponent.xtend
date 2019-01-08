package com.sirolf2009.muse.components

import com.almasb.fxgl.entity.component.Component
import com.almasb.fxgl.entity.components.ViewComponent
import javafx.scene.shape.LineTo
import javafx.scene.shape.MoveTo
import javafx.scene.shape.Path
import com.almasb.fxgl.app.FXGL
import com.sirolf2009.muse.Muse
import com.almasb.fxgl.entity.view.EntityView
import com.almasb.fxgl.entity.components.PositionComponent

class CombinableComponent extends Component {
	
	var Path path
	var ViewComponent view
	var PositionComponent position
	var LineTo line
	
	override onAdded() {
		path = new Path()
		path.getElements().add(new MoveTo() => [
			xProperty().bind(position.xProperty().add(view.getView().getBoundsInLocal().getWidth()/2))
			yProperty().bind(position.yProperty().add(view.getView().getBoundsInLocal().getHeight()/2))
		])
		view.getView().setOnDragDetected [
			line = new LineTo()
			path.getElements().add(line)
			val entityView = new EntityView(path)
			getGame().getGameScene().addGameView(entityView)
		]
		view.getView().setOnDragDone [
			println("dropped")
		]
	}
	
	override onUpdate(double tpf) {
		if(line !== null) {
			line.setX(getGame().getInput().getMouseXWorld())
			line.setY(getGame().getInput().getMouseYWorld())
		}
	}
	
	def getGame() {
		return FXGL.getApp() as Muse
	}
	
}