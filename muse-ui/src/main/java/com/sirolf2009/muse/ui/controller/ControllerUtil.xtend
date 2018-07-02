package com.sirolf2009.muse.ui.controller

import java.io.IOException
import javafx.fxml.FXMLLoader

class ControllerUtil {
	
	def static void load(Object me, String fxml) {
        val fxmlLoader = new FXMLLoader(me.getClass().getResource(fxml)) => [
        	setRoot(me)
        	setController(me)
        ]

        try {
            fxmlLoader.load()
        } catch (IOException exception) {
            throw new RuntimeException(exception)
        }
    }
	
}