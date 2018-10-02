package com.sirolf2009.muse

import java.io.File
import java.net.URLClassLoader
import java.nio.file.Files
import java.util.stream.Collectors

class MuseEngine {

	def run(Project project) {
		val classLoader = project.getJavaSourcePath().load()
		val path = project.getTarget().toPath()		
		val classes = Files.walk(path).filter[Files.isRegularFile(it)].map[
			classLoader.loadClass(subpath(path.size(), size()).join(".").replace(".java", ""))
		].collect(Collectors.toList())
		classes.filter[isAssignableFrom(Publisher)].forEach[
			println(it)
		]
	}	
	
	def static load(File file) {
		new URLClassLoader(#[file.toURI().toURL()])
	}
	
}