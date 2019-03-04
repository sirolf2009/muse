package com.sirolf2009.muse.akka

import akka.actor.AbstractActor
import akka.actor.ActorSystem
import akka.actor.Props
import com.fxgraph.cells.AbstractCell
import com.fxgraph.graph.Graph
import com.fxgraph.layout.AbegoTreeLayout
import java.util.Date
import java.util.Map
import javafx.application.Application
import javafx.application.Platform
import javafx.scene.Scene
import javafx.scene.layout.BorderPane
import javafx.scene.layout.Pane
import javafx.scene.paint.Color
import javafx.scene.shape.Rectangle
import javafx.scene.text.Text
import javafx.stage.Stage
import org.abego.treelayout.Configuration.Location
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import scala.Option
import java.util.HashMap

class AkkaFXGraphServer extends Application {

	override start(Stage primaryStage) throws Exception {
		val root = new BorderPane()

		val graph = new Graph()

		root.setCenter(graph.getCanvas())

		val scene = new Scene(root, 1024, 768)
//		scene.getStylesheets().add(getClass().getResource("/application.css").toExternalForm())
		val system = ActorSystem.create("muse-server-system")
		val actor = system.actorOf(Props.create(ServerActor, graph), "ServerActor")
		actor.tell(new EventSpawn(new Date(), Option.apply(actor)), actor)

		primaryStage.setScene(scene)
		primaryStage.show()
	}

	def static void main(String[] args) {
		launch(args)
	}

	@FinalFieldsConstructor static class ServerActor extends AbstractActor {

		val Graph graph
		val Map<String, ServerCell> cells = new HashMap()

		override createReceive() {
			return receiveBuilder().match(EventSpawn) [
				if(getActor().isDefined()) {
					graph.beginUpdate()
					val actor = getActor().get()
					(0 ..< actor.path().elements().size()).forEach [
						val path = actor.path().getElements().take(it + 1).join("/")
						if(!cells.containsKey(path)) {
							println('''Adding cell «path»''')
							val cell = new ServerCell(path)
							graph.getModel().addCell(cell)
							cells.put(path, cell)
						}
						if(it > 0) {
							val parent = actor.path().getElements().take(it).join("/")
							if(cells.containsKey(parent)) {
								graph.getModel().addEdge(cells.get(parent), cells.get(path))
							}
						}
					]
					Platform.runLater [
						graph.endUpdate()
						graph.layout(new AbegoTreeLayout(200, 200, Location.Top))
					]
				}
			].build()
		}

	}

	@FinalFieldsConstructor static class ServerCell extends AbstractCell {

		val String path

		override getGraphic(Graph graph) {
			val view = new Rectangle(50, 50)

			view.setStroke(Color.DODGERBLUE)
			view.setFill(Color.DODGERBLUE)

			val pane = new Pane(view)
			pane.setPrefSize(50, 50)
			view.widthProperty().bind(pane.prefWidthProperty())
			view.heightProperty().bind(pane.prefHeightProperty())

			pane.getChildren().add(new Text(path))

			return pane
		}

	}

}
