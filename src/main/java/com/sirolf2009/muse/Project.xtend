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

class Project {

	val File location
	var MuseCell rootCell

	new(File location) {
		this.location = location
	}

	def compile() {
		save()

		println("compiling")
		FileUtils.deleteDirectory(getOutputPath())
		val injector = XtendInjectorSingleton.INJECTOR
		val compiler = injector.getInstance(XtendBatchCompiler)
		compiler.setOutputPath(getOutputPath().getAbsolutePath())
		compiler.setTempDirectory(getTempDir().getAbsolutePath())
		compiler.setJavaSourceVersion("1.8")
		compiler.setUseCurrentClassLoaderAsParent(true)
		compiler.setSourcePath(getInputPath().getAbsolutePath())
		if(!compiler.compile()) {
			println("failed")
			throw new IllegalArgumentException("Failed to compile")
		}
		injector.getInstance(CancellationObserver).stop()
		println("done")
	}

	def save() {
		println("saving")
		FileUtils.deleteDirectory(getInputPath())
		save(rootCell)
	}

	def void save(MuseCell cell) {
		println("saving " + cell)
		if(cell instanceof MuseCodeCell) {
			val destination = new File(getInputPath(), cell.getPath()+".xtend")
			destination.getParentFile().mkdirs()
			println('''Writing to «new File(getInputPath(), cell.getPath()).toPath()»
			«cell.getCode().get()»
			###''')
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

	def getOutputPath() {
		return new File(getLocation(), "target")
	}

	def getTempDir() {
		return new File(getLocation(), "tempdir")
	}

}
