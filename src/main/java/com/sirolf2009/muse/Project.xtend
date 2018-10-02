package com.sirolf2009.muse

import com.sirolf2009.muse.cell.MuseCell
import java.io.File
import org.eclipse.xtend.core.XtendInjectorSingleton
import org.eclipse.xtend.core.compiler.batch.XtendBatchCompiler
import org.eclipse.xtend.core.macro.AnnotationProcessor.CancellationObserver
import org.apache.commons.io.FileUtils
import com.sirolf2009.muse.cell.MuseCodeCell
import com.sirolf2009.muse.cell.MuseSquareCell
import java.nio.file.Files
import java.nio.file.StandardOpenOption
import javax.tools.ToolProvider
import javax.tools.DiagnosticCollector
import java.util.stream.Collectors

class Project {

	val File location
	var MuseCell rootCell

	new(File location) {
		this.location = location
	}

	def compile() {
		save()

		FileUtils.deleteDirectory(getJavaSourcePath())
		val injector = XtendInjectorSingleton.INJECTOR
		val compiler = injector.getInstance(XtendBatchCompiler)
		compiler.setOutputPath(getJavaSourcePath().getAbsolutePath())
		compiler.setTempDirectory(getTempDir().getAbsolutePath())
		compiler.setJavaSourceVersion("1.8")
		compiler.setUseCurrentClassLoaderAsParent(true)
		compiler.setSourcePath(getInputPath().getAbsolutePath())
		if(!compiler.compile()) {
			throw new IllegalArgumentException("Failed to compile")
		}
		injector.getInstance(CancellationObserver).stop()
		
		val diagnostics = new DiagnosticCollector()
		val javac = ToolProvider.getSystemJavaCompiler()
		val files = javac.getStandardFileManager(new DiagnosticCollector(), null, null)
		val sources = files.getJavaFileObjectsFromFiles(Files.walk(getTarget().toPath()).filter[Files.isRegularFile(it) && getFileName().endsWith(".java")].map[toFile()].collect(Collectors.toList()))
		val task = javac.getTask(null, files, diagnostics, null, null, sources)
		task.call()
	}

	def save() {
		FileUtils.deleteDirectory(getInputPath())
		save(rootCell)
	}

	def void save(MuseCell cell) {
		if(cell instanceof MuseCodeCell) {
			val destination = new File(getInputPath(), cell.getPath()+".xtend")
			destination.getParentFile().mkdirs()
			Files.write(destination.toPath(), cell.getCode().get().getBytes(), StandardOpenOption.CREATE)
		} else if(cell instanceof MuseSquareCell) {
			cell.getChildren().forEach[save(it)]
		}
	}

	def getRootCell() {
		return rootCell
	}

	def setRootCell(MuseCell rootCell) {
		this.rootCell = rootCell
	}

	def getLocation() {
		return location
	}

	def getInputPath() {
		return new File(getLocation(), "src")
	}

	def getJavaSourcePath() {
		return new File(getLocation(), "java")
	}

	def getTarget() {
		return new File(getLocation(), "target")
	}

	def getTempDir() {
		return new File(getLocation(), "tempdir")
	}

}
