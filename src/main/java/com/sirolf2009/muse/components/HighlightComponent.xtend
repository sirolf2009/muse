package com.sirolf2009.muse.components

import com.almasb.fxgl.app.FXGL
import com.almasb.fxgl.entity.component.Component
import com.sirolf2009.muse.Muse
import javafx.scene.effect.Glow
import javafx.geometry.Point2D
import com.almasb.fxgl.entity.components.BoundingBoxComponent
import com.almasb.fxgl.entity.components.ViewComponent

class HighlightComponent extends Component {
	
	var ViewComponent view
	val glow = new Glow(0.8)
	
	override onUpdate(double tpf) {
		if(view.getView().getBoundsInParent().contains((FXGL.getApp() as Muse).getInput().getMousePositionUI())) {
			getEntity().getView().setEffect(glow)
		} else {
			getEntity().getView().setEffect(null)
		}
	}
	
	def isMouseHovering() {
		 val mouse = (FXGL.getApp() as Muse).getInput().getMousePositionWorld()
		 val bbox = getEntity().getBoundingBoxComponent()
		 return mouse.isInBBox(bbox)
	}
	
	def isInBBox(Point2D point, BoundingBoxComponent bbox) {
		return point.getX() > bbox.getMinXWorld() && point.getX() < bbox.getMaxXWorld() && point.getY() > bbox.getMinYWorld() && point.getY() < bbox.getMaxYWorld()
	}
	
}