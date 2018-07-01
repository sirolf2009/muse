package com.sirolf2009.muse.ui.controller

import com.sirolf2009.muse.ui.model.ConnectionDetails
import io.reactivex.Observable
import io.reactivex.rxjavafx.observables.JavaFxObservable
import io.reactivex.subjects.PublishSubject
import java.io.File
import java.io.FileOutputStream
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.ListView
import javafx.scene.control.TextField
import javafx.scene.layout.AnchorPane

import static extension com.sirolf2009.muse.core.AvroExtensions.*

class ConnectionManagerController extends AnchorPane {
	
	static val savedConnectionsFolder = new File(".config/connections")

	@FXML var TextField connectionName
	@FXML var TextField bootstrapServer
	@FXML var TextField clientID

	@FXML var Button saveAndConnect
	@FXML var Button save
	@FXML var Button connect

	@FXML var ListView<ConnectionDetails> savedConnections

	new() {
		ControllerUtil.load(this, "/fxml/ConnectionManager.fxml")
	}

	@FXML
	def void initialize() {
		val saveConnection = PublishSubject.<ConnectionDetails>create()
		saveConnection.map[toBytes(ConnectionDetails.SCHEMA$)].subscribe [
		]
		val connectToConnection = PublishSubject.<ConnectionDetails>create()
		connectToConnection.subscribe[]

		JavaFxObservable.actionEventsOf(save).map[
			new ConnectionDetails(connectionName.getText(), #[bootstrapServer.getText()], clientID.getText())
		].forEach[
			saveConnection.onNext(it)
		]
		
		JavaFxObservable.actionEventsOf(connect).map[
			new ConnectionDetails(connectionName.getText(), #[bootstrapServer.getText()], clientID.getText())
		].forEach[
			connectToConnection.onNext(it)
		]
		JavaFxObservable.actionEventsOf(saveAndConnect).map[
			new ConnectionDetails(connectionName.getText(), #[bootstrapServer.getText()], clientID.getText())
		].forEach [
			saveConnection.onNext(it)
			connectToConnection.onNext(it)
		]
	}
	
	def static void write(ConnectionDetails details) {
		write(details, new File(savedConnectionsFolder, details.getName().toString()))
	}
	
	def static void write(ConnectionDetails details, File file) {
		val out = new FileOutputStream(file)
		out.write(details.toBytes(ConnectionDetails.SCHEMA$))
		out.close()
	}
	
	def Observable<ConnectionDetails> readConnections() {
		return Observable.fromArray(savedConnectionsFolder.listFiles()).map[
			
		]
	}

}
