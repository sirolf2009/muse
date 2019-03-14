package com.sirolf2009.muse

import akka.actor.AbstractActor
import com.fxgraph.graph.Graph
import com.fxgraph.graph.IEdge
import com.sirolf2009.muse.actorgraph.ServerCell
import java.io.Serializable
import javafx.application.Platform
import javafx.beans.property.BooleanProperty
import javafx.beans.property.IntegerProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor class FXGraphActor extends AbstractActor {

	val Graph graph
	val BooleanProperty locked
	val IntegerProperty cursor
	val ObservableList<GraphOperation> actions
	val ObservableList<GraphOperation> lockedQueue = FXCollections.observableArrayList()

	override createReceive() {
		receiveBuilder().match(GraphOperation) [
			if(!locked.get()) {
				actions.add(it)
				cursor.set(actions.size() - 1)
				Platform.runLater [
					apply(graph)
					graph.endUpdate()
				]
			} else {
				lockedQueue.add(it)
			}
		].match(Lock) [
			locked.set(true)
		].match(Unlock) [
			locked.set(false)
			actions.addAll(lockedQueue)
			lockedQueue.clear()
			navigateTo(actions.size() - 1)
		].match(NavigateTo) [
			navigateTo(index)
		].match(CursorRequest) [
			getSender().tell(new CursorResponse(cursor.get()), getSelf())
		].build()
	}

	def navigateTo(int index) {
		if(index > cursor.get()) {
			(cursor.get() + 1 .. index).map[actions.get(it)].forEach[apply(graph)]
		}
		if(cursor.get() > index) {
			(index + 1 .. cursor.get()).toList().reverse().map[actions.get(it)].forEach[unapply(graph)]
		}
		Platform.runLater [
			cursor.set(index)
			graph.endUpdate()
		]
	}

	static interface GraphOperation {

		def void apply(Graph graph)

		def void unapply(Graph graph)

	}

	@Data static class AddNode implements Serializable, GraphOperation {
		ServerCell cell

		override apply(Graph graph) {
			graph.getModel().addCell(cell)
		}

		override unapply(Graph graph) {
			graph.getModel().removeCell(cell)
		}

		override toString() {
			return '''AddNode [«cell»]'''
		}

	}

	@Data static class AddEdge implements Serializable, GraphOperation {
		IEdge edge

		override apply(Graph graph) {
			graph.getModel().addEdge(edge)
		}

		override unapply(Graph graph) {
			graph.getModel().removeEdge(edge)
		}

		override toString() {
			return '''AddEdge [«edge»]'''
		}

	}

	static class Lock implements Serializable {
	}

	static class Unlock implements Serializable {
	}

	@Data static class NavigateTo implements Serializable {
		int index
	}

	@Data static class CursorRequest implements Serializable {
	}

	@Data static class CursorResponse implements Serializable {
		int cursor
	}

}
