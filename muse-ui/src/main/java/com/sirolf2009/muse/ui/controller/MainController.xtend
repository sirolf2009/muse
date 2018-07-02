package com.sirolf2009.muse.ui.controller

import javafx.fxml.FXML
import javafx.scene.control.Tab
import javafx.scene.control.TabPane

class MainController {
	
	@FXML var TabPane contentTabPane
	
	@FXML
	def void initialize() {
		openConnectionManager()
		contentTabPane.getTabs().add(new Tab("Connection", new ConnectionController()) => [
			contentTabPane.getSelectionModel().select(it)
		])
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