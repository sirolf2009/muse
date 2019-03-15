package com.sirolf2009.muse.messagetable

import akka.actor.ActorPath
import com.sirolf2009.muse.EventMessage
import java.util.Date
import java.util.function.Function
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.scene.control.TableCell
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.control.Tooltip
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

class MessageTable extends TableView<EventMessage> {

	new() {
		getColumns().addAll(new TableColumn<EventMessage, Date>("Date") => [
			setCellValueFactory [ return new SimpleObjectProperty(getValue().getDate()) ]
		], new TableColumn<EventMessage, EventMessage>("From") => [
			setCellValueFactory [ return new SimpleObjectProperty(getValue()) ]
			setCellFactory [ return new TableCellActorPath([getEnvelope().sender().path()]) ]
		], new TableColumn<EventMessage, EventMessage>("To") => [
			setCellValueFactory [ return new SimpleObjectProperty(getValue()) ]
			setCellFactory [ return new TableCellActorPath([getTarget().path()]) ]
		], new TableColumn<EventMessage, String>("Message") => [
			setCellValueFactory [ return new SimpleStringProperty(getValue().getEnvelope().message().toString())]
			prefWidthProperty().bind(MessageTable.this.widthProperty())
		])
	}

	@FinalFieldsConstructor static class TableCellActorPath extends TableCell<EventMessage, EventMessage> {
		
		val Function<EventMessage, ActorPath> mapper
		
		override protected updateItem(EventMessage item, boolean empty) {
			if(item === null || empty) {
				setText(null)
				setTooltip(null)
			} else {
				val path = mapper.apply(item)
				setText(path.name())
				setTooltip(new Tooltip(path.toSerializationFormat()))
			}
		}

	}

}
