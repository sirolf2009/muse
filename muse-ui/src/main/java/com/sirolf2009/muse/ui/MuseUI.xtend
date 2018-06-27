package com.sirolf2009.muse.ui

import javafx.application.Application
import javafx.scene.Scene
import javafx.scene.layout.BorderPane
import javafx.stage.Stage
import com.sirolf2009.muse.ui.model.Connection
import com.sirolf2009.muse.ui.properties.LocalProperties

class MuseUI extends Application {
	
	def static void main(String[] args) throws Exception {
        launch(args)
    }

    override void start(Stage stage) throws Exception {
    	new Connection(new LocalProperties("MUSE-INTERNAL"))
    	
    	val sceneRoot = new BorderPane()

        val scene = new Scene(sceneRoot, 1200, 600)
		scene.getStylesheets().add(getClass().getResource("/application.css").toExternalForm())

        stage.setTitle("Hello JavaFX and Maven")
        stage.setScene(scene)
        stage.show()
    }
	
}