package com.sirolf2009.muse.messagetable

import akka.actor.ActorPath
import com.sirolf2009.muse.actorgraph.IGraphic
import com.sirolf2009.muse.event.EventMessage
import java.util.Date
import java.util.function.Function
import javafx.beans.property.SimpleObjectProperty
import javafx.scene.control.TableCell
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.control.Tooltip
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

class MessageTable extends TableView<EventMessage> {

	new() {
		getStyleClass().add("message-table")
		val dateColumn = new TableColumn<EventMessage, Date>("Date") => [
			setCellValueFactory [return new SimpleObjectProperty(getValue().getDate())]
			setPrefWidth(210)
		]
		val fromColumn = new TableColumn<EventMessage, EventMessage>("From") => [
			setCellValueFactory [return new SimpleObjectProperty(getValue())]
			setCellFactory [return new TableCellActorPath([getEnvelope().sender().path()])]
		]
		val toColumn = new TableColumn<EventMessage, EventMessage>("To") => [
			setCellValueFactory [return new SimpleObjectProperty(getValue())]
			setCellFactory [return new TableCellActorPath([getTarget().path()])]
		]
		val messageColumn = new TableColumn<EventMessage, EventMessage>("Message") => [
			setCellValueFactory [return new SimpleObjectProperty(getValue())]
			setCellFactory [return new TableCellMessage()]
			prefWidthProperty().bind(MessageTable.this.widthProperty().subtract(dateColumn.widthProperty()).subtract(fromColumn.widthProperty()).subtract(toColumn.widthProperty()))
		]
		getColumns().addAll(dateColumn, fromColumn, toColumn, messageColumn)
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

	static class TableCellMessage extends TableCell<EventMessage, EventMessage> {

		override protected updateItem(EventMessage item, boolean empty) {
			try {
				if(item === null || empty) {
					setText(null)
					setGraphic(null)
				} else {
					if(item.getEnvelope().message() instanceof IGraphic) {
						setText(null)
						setGraphic((item.getEnvelope().message() as IGraphic).getNode())
					} else {
						setText(item.getEnvelope().message().toString())
						setGraphic(null)
					}
				}
			} catch(Exception e) {
				e.printStackTrace
			}
		}

	}

}
