package com.sirolf2009.muse.client

import akka.actor.ActorRef
import com.sirolf2009.muse.MuseConnect.NewAppConnection
import java.util.Optional
import javafx.beans.binding.Bindings
import javafx.beans.property.SimpleBooleanProperty
import javafx.scene.Node
import javafx.scene.image.Image
import javafx.scene.image.ImageView
import org.eclipse.xtend.lib.annotations.Data

interface ConnectionTreeItem {

	def Optional<String> getText()

	def Optional<Node> getGraphic()

	@Data static class Servers implements ConnectionTreeItem {

		override getText() {
			return Optional.empty()
		}

		override getGraphic() {
			return Optional.empty()
		}

	}

	@Data static class Server implements ConnectionTreeItem {

		val ActorRef actor

		override getText() {
			return Optional.of(actor.path().address().hostPort())
		}

		override getGraphic() {
			val icon = new ImageView("server.png") => [
				setFitWidth(28)
				setFitHeight(28)
			]
			return Optional.of(icon)
		}

	}

	@Data static class Connection implements ConnectionTreeItem {

		val connected = new SimpleBooleanProperty(false)
		val NewAppConnection connection

		override getText() {
			return Optional.of(connection.getActorSystem())
		}

		override getGraphic() {
			val disconnected = new Image("broken-link.png")
			val connected = new Image("web-link.png")
			val image = Bindings.createObjectBinding([
				if(this.connected.get())
					return connected
				return disconnected
			], this.connected)
			val icon = new ImageView("broken-link.png") => [
				imageProperty.bind(image)
				setFitWidth(28)
				setFitHeight(28)
			]
			return Optional.of(icon)
		}

	}

}
