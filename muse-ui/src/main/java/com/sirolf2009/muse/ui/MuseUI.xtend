package com.sirolf2009.muse.ui

import com.sirolf2009.muse.ui.model.Connection
import com.sirolf2009.muse.ui.properties.LocalProperties
import javafx.application.Application
import javafx.fxml.FXMLLoader
import javafx.scene.Parent
import javafx.scene.Scene
import javafx.stage.Stage

class MuseUI extends Application {
	
	def static void main(String[] args) throws Exception {
        launch(args)
    }

    override void start(Stage stage) throws Exception {
    	new Connection(new LocalProperties("MUSE-INTERNAL"))
    	
    	val loader = new FXMLLoader()
        val rootNode = loader.load(getClass().getResourceAsStream("/fxml/Main.fxml")) as Parent
    	
        val scene = new Scene(rootNode, 1200, 600)
		scene.getStylesheets().add(getClass().getResource("/application.css").toExternalForm())

        stage.setTitle("Hello JavaFX and Maven")
        stage.setScene(scene)
        stage.show()
    }
	
}