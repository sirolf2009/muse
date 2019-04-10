package com.sirolf2009.muse.actorgraph

import akka.actor.AbstractActor
import akka.actor.ActorRef
import akka.actor.Props
import akka.event.Logging
import com.fxgraph.graph.Graph
import com.fxgraph.graph.ICell
import com.sirolf2009.muse.FXGraphActor
import com.sirolf2009.muse.FXGraphActor.AddEdge
import com.sirolf2009.muse.FXGraphActor.AddNode
import com.sirolf2009.muse.FXGraphActor.GraphOperation
import com.sirolf2009.muse.FXGraphActor.Lock
import com.sirolf2009.muse.FXGraphActor.NavigateTo
import com.sirolf2009.muse.FXGraphActor.Unlock
import com.sirolf2009.muse.InstanceActor.FocusMessage
import com.sirolf2009.muse.event.Event
import com.sirolf2009.muse.event.EventMessage
import com.sirolf2009.muse.event.EventSpawn
import java.io.Serializable
import java.util.HashMap
import java.util.LinkedList
import java.util.Map
import java.util.concurrent.atomic.AtomicReference
import javafx.animation.PathTransition
import javafx.application.Platform
import javafx.beans.property.SimpleBooleanProperty
import javafx.beans.property.SimpleIntegerProperty
import javafx.collections.FXCollections
import javafx.collections.ListChangeListener
import javafx.scene.Node
import javafx.scene.control.Label
import javafx.scene.shape.ArcTo
import javafx.scene.shape.LineTo
import javafx.scene.shape.MoveTo
import javafx.scene.shape.Path
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
	val messages = new LinkedList<Event>()
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
			messages.add(it)
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
								graphActor.tell(new AddEdge(new ServerEdge(cells.get(parent), cells.get(path))), getSelf())
							}
						}
					]
				]
			}
		].match(EventMessage) [
			messages.add(it)
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
							getStyleClass().add("message")
						]
				graphActor.tell(new ShowMessage(message, senderCell, receiverCell), getSelf())
			} else {				
				log.error('''
				Failed to find corresponding receiver/sender.
				Message sender: «sender()»
				Message: «it»
				sender: «senderCell» «senderPath»
				receiver: «receiverCell» «receiverPath»
				cells: «cells»''')
			}
		].match(FocusMessage) [
			graph.getLock().setSelected(true)
			graphActor.tell(new NavigateTo(messages.indexOf(getEventMessage())), getSelf())
		].build()
	}

	@Data @FinalFieldsConstructor static class ShowMessage implements GraphOperation, Serializable, IGraphic {

		val transient Node message
		val transient ICell senderCell
		val transient ICell receiverCell
		val transient AtomicReference<PathTransition> animation = new AtomicReference()

		override apply(Graph graph) {
			val path = getAnimationPath(graph, senderCell, receiverCell)

			Platform.runLater [
				try {
					graph.getCanvas().getChildren().add(message)
					message.toFront()
					new PathTransition(Duration.seconds(1), path, message) => [
						onFinished = [
							graph.getCanvas().getChildren().remove(message)
						]
						playAnimation()
					]
				} catch(Exception e) {
					throw new RuntimeException('''Failed to unapply «message»''', e)
				}
			]
		}

		override unapply(Graph graph) {
			val path = getAnimationPath(graph, receiverCell, senderCell)

			Platform.runLater [
				try {
					new PathTransition(Duration.seconds(1), path, message) => [
						graph.getCanvas().getChildren().add(message)
						message.toFront()
						onFinished = [
							graph.getCanvas().getChildren().remove(message)
						]
						playAnimation()
					]
				} catch(Exception e) {
					throw new RuntimeException('''Failed to unapply «message»''', e)
				}
			]
		}

		def playAnimation(PathTransition anim) {
			if(animation.get() !== null) {
				animation.get().stop()
			}
			animation.set(anim)
			anim.play()
		}

		def getAnimationPath(Graph graph, ICell from, ICell to) {
			if(from.equals(to)) {
				return getCircle(graph, from)
			}
			return getPath(graph, from, to)
		}

		def getPath(Graph graph, ICell from, ICell to) {
			val path = new Path()
			path.getElements().add(new MoveTo(graph.getGraphic(from).getLayoutX(), graph.getGraphic(from).getLayoutY()))
			val lineTo = new LineTo()
			lineTo.xProperty().bind(graph.getGraphic(to).layoutXProperty())
			lineTo.yProperty().bind(graph.getGraphic(to).layoutYProperty())
			path.getElements().add(lineTo)
			return path
		}

		def getCircle(Graph graph, ICell cell) {
			val path = new Path()
			val x = graph.getGraphic(cell).getLayoutX()
			val y = graph.getGraphic(cell).getLayoutY()
			path.getElements().add(new MoveTo(x, y))
			path.getElements().add(new ArcTo(75, 75, 0, x - 1, y - 1, true, false))
			return path
		}
		
		override getNode() {
			if(message !== null) {
				return message
			} else {
				return new Label("ShowMessage") => [
					getStyleClass().add("message")
				]
			}
		}
		
		override toString() {
			return '''ShowMessage [«senderCell» -«node»-> «receiverCell»'''
		}

	}

}
