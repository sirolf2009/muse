package com.sirolf2009.muse.sequencediagram

import akka.actor.AbstractActor
import akka.actor.ActorRef
import com.fxgraph.edges.AbstractEdge
import com.fxgraph.graph.Arrow
import com.fxgraph.graph.Graph
import com.fxgraph.graph.SequenceDiagram
import com.fxgraph.graph.SequenceDiagram.ActorCell
import com.fxgraph.graph.SequenceDiagram.IActorCell
import com.fxgraph.graph.SequenceDiagram.IMessageEdge
import com.google.common.util.concurrent.AtomicDouble
import com.sirolf2009.muse.EventMessage
import com.sirolf2009.muse.MuseServer.ShowScreen
import com.sirolf2009.muse.actorgraph.IGraphic
import java.util.List
import java.util.function.Supplier
import java.util.stream.Collectors
import java.util.stream.Stream
import javafx.beans.binding.DoubleBinding
import javafx.beans.property.DoubleProperty
import javafx.beans.property.SimpleDoubleProperty
import javafx.scene.Group
import javafx.scene.layout.AnchorPane
import javafx.scene.layout.Pane
import javafx.scene.paint.Color
import javafx.scene.shape.Line
import javafx.scene.text.Text
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor class SequenceDiagramActor extends AbstractActor {

	val ActorRef serverActor

	override createReceive() {
		return receiveBuilder().match(ShowSequenceDiagram) [
			val seqDiagram = new SequenceDiagram()
			val messageCount = messages.size()
			val lifelineLength = new SimpleDoubleProperty((messageCount * 200).doubleValue())
			val actors = messages.stream().flatMap [
				Stream.of(getEnvelope().sender(), getTarget())
			].distinct().map [
				path().getElements().last()
			].collect(Collectors.toMap([it], [new ActorCell(it, lifelineLength)]))
			actors.values().forEach[seqDiagram.addActor(it)]

			val maxWidth = new AtomicDouble(-1)
			val maxHeight = new AtomicDouble(-1)
			messages.stream().map [
				val from = actors.get(getEnvelope().sender().path().getElements().last())
				val to = actors.get(getTarget().path().getElements().last())
				new MuseMessageEdge(from, to, getEnvelope().message())
			].forEach [
				seqDiagram.addMessage(it)
				if(seqDiagram.getGraphic(it).getPrefWidth() > maxWidth.get()) maxWidth.set(seqDiagram.getGraphic(it).getPrefWidth())
				if(seqDiagram.getGraphic(it).getPrefHeight() > maxHeight.get()) maxHeight.set(seqDiagram.getGraphic(it).getPrefHeight())
			]
			seqDiagram.setVerticalSpacing(maxHeight.get() + 100d)
			seqDiagram.setHorizontalSpacing(maxWidth.get() + 50d)
			lifelineLength.set(messageCount * (maxHeight.get() + 50d))

			seqDiagram.endUpdate()
			seqDiagram.layout()
			serverActor.tell(new ShowScreen("Sequence Diagram", seqDiagram.getCanvas()), getSelf())
		].build()
	}

	@Data static class ShowSequenceDiagram {
		val List<EventMessage> messages
	}

	static class MuseMessageEdge extends AbstractEdge implements IMessageEdge {

		val yOffsetProperty = new SimpleDoubleProperty()
		val Object message

		new(IActorCell source, IActorCell target, Object message) {
			super(source, target)
			this.message = message
		}

		override getGraphic(Graph graph) {
			val Group group = new Group()
			val Supplier<Line> whiteLine = [
				val Line line = new Line()
				line.setStroke(Color.AZURE)
				return line
			]
			val arrow = new Arrow(whiteLine.get(), whiteLine.get(), whiteLine.get())
			val DoubleBinding sourceX = getSource().getXAnchor(graph, this)
			val DoubleBinding sourceY = getSource().getYAnchor(graph, this).add(yOffsetProperty)
			val DoubleBinding targetX = getTarget().getXAnchor(graph, this)
			val DoubleBinding targetY = getTarget().getYAnchor(graph, this).add(yOffsetProperty)
			arrow.startXProperty().bind(sourceX)
			arrow.startYProperty().bind(sourceY)
			arrow.endXProperty().bind(targetX)
			arrow.endYProperty().bind(targetY)
			group.getChildren().add(arrow)

			val icon = if(message instanceof IGraphic) {
					val graphic = message.getNode()
					val icon = new AnchorPane(graphic)
					icon.layoutXProperty().bind(arrow.startXProperty().add(arrow.endXProperty()).divide(2).subtract(icon.widthProperty().divide(2)))
					icon.layoutYProperty().bind(arrow.startYProperty().add(arrow.endYProperty()).divide(2).subtract(icon.heightProperty().divide(2)))
					icon
				} else {
					val DoubleProperty textWidth = new SimpleDoubleProperty()
					val DoubleProperty textHeight = new SimpleDoubleProperty()
					val Text text = new Text(message.toString())
					text.getStyleClass().add("edge-text")
					text.xProperty().bind(arrow.startXProperty().add(arrow.endXProperty()).divide(2).subtract(textWidth.divide(2)))
					text.yProperty().bind(arrow.startYProperty().add(arrow.endYProperty()).divide(2).subtract(textHeight.divide(2)))
					val Runnable recalculateWidth = [
						{
							textWidth.set(text.getLayoutBounds().getWidth())
							textHeight.set(text.getLayoutBounds().getHeight())
						}
					]
					text.parentProperty().addListener([obs, oldVal, newVal|recalculateWidth.run()])
					text.textProperty().addListener([obs, oldVal, newVal|recalculateWidth.run()])
					text
				}
			group.getChildren().add(icon)
			val Pane pane = new AnchorPane(group)
			pane.getStyleClass().add("message-edge")
			return pane
		}

		override yOffsetProperty() {
			return yOffsetProperty
		}

	}

}
