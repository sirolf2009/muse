package com.sirolf2009.muse.akka

import akka.actor.AbstractActor
import akka.actor.ActorRef
import akka.actor.Props
import akka.event.Logging
import com.fxgraph.edges.Edge
import com.fxgraph.graph.Graph
import com.fxgraph.graph.ICell
import com.sirolf2009.muse.akka.AkkaFXGraphServer.IGraphic
import com.sirolf2009.muse.akka.FXGraphActor.AddEdge
import com.sirolf2009.muse.akka.FXGraphActor.AddNode
import com.sirolf2009.muse.akka.FXGraphActor.GraphOperation
import com.sirolf2009.muse.akka.FXGraphActor.Lock
import com.sirolf2009.muse.akka.FXGraphActor.NavigateTo
import com.sirolf2009.muse.akka.FXGraphActor.Unlock
import com.sirolf2009.muse.akka.server.graph.ServerCell
import java.util.HashMap
import java.util.Map
import javafx.animation.PathTransition
import javafx.application.Platform
import javafx.beans.property.SimpleBooleanProperty
import javafx.beans.property.SimpleIntegerProperty
import javafx.collections.FXCollections
import javafx.collections.ListChangeListener
import javafx.scene.Node
import javafx.scene.control.Label
import javafx.scene.shape.LineTo
import javafx.scene.shape.MoveTo
import javafx.scene.shape.Path
import javafx.scene.text.Font
import javafx.util.Duration
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor class ActorGraphActor extends AbstractActor {

	val ActorGraph graph
	var ActorRef graphActor
	val Map<String, ServerCell> cells = new HashMap()
	val locked = new SimpleBooleanProperty()
	val cursor = new SimpleIntegerProperty()
	val actions = FXCollections.<GraphOperation>observableArrayList()
	val log = Logging.getLogger(getContext().getSystem(), this)

	override preStart() throws Exception {
		graphActor = context().actorOf(Props.create(FXGraphActor, graph.getGraph(), locked, cursor, actions), "fxgraph")
		graph.getLock().selectedProperty().addListener [ obs, oldVal, newVal |
			val message = if(newVal) new Lock() else new Unlock()
			graphActor.tell(message, getSelf())
		]
		actions.addListener(new ListChangeListener<GraphOperation>() {
			override onChanged(Change<? extends GraphOperation> c) {
				graph.getSlider().setMax(actions.size() - 1)
			}
		})
		cursor.addListener[obs, oldVal, newVal|graph.getSlider().setValue(newVal.intValue())]
		graph.getSlider().valueProperty().addListener [ obs, oldVal, newVal |
			if(graph.getSlider().isPressed() && newVal.intValue() != cursor.getValue()) {
				graphActor.tell(new NavigateTo(newVal.intValue()), getSelf())
			}
		]
	}

	override createReceive() {
		return receiveBuilder().match(EventSpawn) [
			if(getActor().isDefined()) {
				Platform.runLater [
					val actor = getActor().get()
					(0 ..< actor.path().elements().size()).forEach [
						val name = actor.path().getElements().get(it)
						val path = actor.path().getElements().take(it + 1).join("/")
						if(!cells.containsKey(path)) {
							val cell = new ServerCell(name)
							cells.put(path, cell)
							graphActor.tell(new AddNode(cell), getSelf())
						}
						if(it > 0) {
							val parent = actor.path().getElements().take(it).join("/")
							if(cells.containsKey(parent)) {
								graphActor.tell(new AddEdge(new Edge(cells.get(parent), cells.get(path))), getSelf())
							}
						}
					]
				]
			}
		].match(EventMessage) [
			val senderPath = getEnvelope().sender().path().getElements().join("/")
			val senderCell = cells.get(senderPath)
			val receiverPath = getTarget().path().getElements().join("/")
			val receiverCell = cells.get(receiverPath)
			if(senderCell !== null && receiverCell !== null) {
				val messageObj = getEnvelope().message()
				val message = if(messageObj instanceof IGraphic)
						messageObj.getNode()
					else
						new Label(getEnvelope().message().toString()) => [
							setFont(new Font("Verdana", 8))
							setStyle('''
							-fx-background-color: aquamarine;
							-fx-background-radius: 16.4, 15;''')
						]
				graphActor.tell(new ShowMessage(message, senderCell, receiverCell), getSelf())
			} else {
				log.error('''
				Failed to find corresponding receiver/sender.
				Message: «it»
				sender: «senderCell» «senderPath»
				receiver: «receiverCell» «receiverPath»
				cells: «cells»''')
			}
		].build()
	}

	@Data static class ShowMessage implements GraphOperation {

		val Node message
		val ICell senderCell
		val ICell receiverCell

		override apply(Graph graph) {
			val path = getPath(graph, senderCell, receiverCell)

			Platform.runLater [
				graph.getCanvas().getChildren().add(message)
				new PathTransition(Duration.seconds(1), path, message) => [
					onFinished = [graph.getCanvas().getChildren().remove(message)]
					play()
				]
			]
		}

		override unapply(Graph graph) {
			val path = getPath(graph, receiverCell, senderCell)
			
			Platform.runLater [
				new PathTransition(Duration.seconds(1), path, message) => [
					graph.getCanvas().getChildren().add(message)
					onFinished = [graph.getCanvas().getChildren().remove(message)]
					play()
				]
			]
		}

		def getPath(Graph graph, ICell from, ICell to) {
			val path = new Path()
			path.getElements().add(new MoveTo(graph.getGraphic(from).getLayoutX(), graph.getGraphic(to).getLayoutY()))
			val lineTo = new LineTo()
			lineTo.xProperty().bind(graph.getGraphic(to).layoutXProperty())
			lineTo.yProperty().bind(graph.getGraphic(to).layoutYProperty())
			path.getElements().add(lineTo)
			return path
		}

	}

}
