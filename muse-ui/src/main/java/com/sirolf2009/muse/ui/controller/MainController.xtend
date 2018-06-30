package com.sirolf2009.muse.ui.controller

import javafx.fxml.FXML
import javafx.scene.control.TabPane
import javafx.scene.control.Tab

class MainController {
	
	@FXML var TabPane contentTabPane
	
	@FXML
	def void initialize() {
		openConnectionManager()
	}
	
	def void openConnectionManager() {
		contentTabPane.getTabs().add(new Tab("Connection Manager", new ConnectionManagerController()) => [
			contentTabPane.getSelectionModel().select(it)
		])
	}
	
	def void close() {
		System.exit(0)
	}
	
}