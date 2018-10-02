package com.sirolf2009.muse

import java.io.File
import java.net.URLClassLoader

class MuseEngine {
	
	def static load(File file) {
		new URLClassLoader(#[file.toURI().toURL()])
	}
	
}