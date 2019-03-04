package com.sirolf2009.muse

import com.sirolf2009.muse.interfaces.IConnectable
import com.sirolf2009.muse.interfaces.IConnector
import groovy.lang.Closure
import groovy.lang.GroovyObjectSupport
import groovy.lang.GroovyShell
import groovy.lang.MissingMethodException
import io.reactivex.Observable
import io.reactivex.Observer
import io.reactivex.subjects.PublishSubject
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Map
import org.codehaus.groovy.control.CompilerConfiguration
import org.codehaus.groovy.control.customizers.ImportCustomizer

class Component {

	/**
	 * SimpleSupplier
	 * Component.create {
	 *  output "output1" {
	 *   data Observable.interval(1, TimeUnit.SECONDS).map[System.currentTimeMillis()].subscribeOn(Schedulers.io())
	 *  }
	 * }
	 * 
	 * SimpleConverter
	 * Component.create {
	 *  input "input1" new SubjectConnector(this, PublishSubject.<Long>create())
	 *  output "output1" new SubjectConnector(this, PublishSubject.<Long>create())
	 * 
	 *  input1.getData().map[new Date(it)].subscribe(output1.getObserver())
	 * }
	 */
	val Map<String, Component.IConnectorBuilder> inputs = new HashMap()
	val Map<String, Component.IConnectorBuilder> outputs = new HashMap()
	val List<Closure<?>> initializers = new ArrayList()

	def static compile(String code) {
		try {
			val importCustomizer = new ImportCustomizer()
			importCustomizer.addImport("Component", "com.sirolf2009.muse.Component")
			importCustomizer.addStaticStars("com.sirolf2009.muse.Component")
			val config = new CompilerConfiguration()
			config.addCompilationCustomizers(importCustomizer)
			val shell = new GroovyShell(config)
			(shell.evaluate(code) as Component).build()
		} catch (Exception e) {
			throw new RuntimeException('''
			Failed to compile 
			«code»''', e)
		}
	}

	def static create(Closure init) {
		val component = new Component()
		init.setDelegate(component)
		init.call()
		return component
	}

	def input(String name, Closure init) {
		val builder = new ConnectorBuilder()
		init.setDelegate(builder)
		init.call()
		inputs.put(name, builder)
	}

	def input(String name) {
		inputs.put(name, new SubjectConnectorBuilder())
	}

	def output(String name, Closure init) {
		val builder = new ConnectorBuilder()
		init.setDelegate(builder)
		init.call()
		outputs.put(name, builder)
	}

	def output(String name) {
		outputs.put(name, new SubjectConnectorBuilder())
	}

	def init(Closure<?> init) {
		initializers.add(init)
	}

	def methodMissing(String name, Object[] args) {
		println("missing method " + name)
		if (inputs.containsKey(name)) {
			return inputs.get(name)
		} else if (outputs.containsKey(name)) {
			return outputs.get(name)
		} else {
			throw new MissingMethodException(name, getClass(), args)
		}
	}

	def build() {
		return new GroovyConnectable(inputs, outputs, initializers)
	}

	static interface IConnectorBuilder {
		def IConnector build(IConnectable connectable)
	}

	static class ConnectorBuilder implements IConnectorBuilder {

		var Observable<?> data
		var Observer<?> observer

		def void data(Observable<?> data) {
			this.data = data
		}

		override build(IConnectable connectable) {
			return new IConnector {

				override getConnectable() {
					connectable
				}

				override getData() {
					return data
				}

				override getObserver() {
					return observer
				}

			}
		}

	}

	static class SubjectConnectorBuilder implements IConnectorBuilder {

		override build(IConnectable connectable) {
			return new SubjectConnector(connectable, PublishSubject.create())
		}

	}

	static class GroovyConnectable extends AbstractConnectable {

		val Map<String, IConnector> inputs
		val Map<String, IConnector> outputs

		new(Map<String, Component.IConnectorBuilder> inputs, Map<String, Component.IConnectorBuilder> outputs,
			List<Closure<?>> initializers) {
			this.inputs = inputs.entrySet().map[pair|pair.getKey() -> pair.getValue().build(this)].toMap([getKey()], [
				getValue()
			])
			this.outputs = outputs.entrySet().map[pair|pair.getKey() -> pair.getValue().build(this)].toMap([getKey()], [
				getValue()
			])
			val support = new GroovyObjectSupport() {
				def methodMissing(String name, Object args) {
					if (inputs.containsKey(name)) {
						return GroovyConnectable.this.inputs.get(name).getData()
					} else if (outputs.containsKey(name)) {
						return GroovyConnectable.this.outputs.get(name).getObserver()
					}
				}
			}
			initializers.forEach [
				delegate = support
				call()
			]
		}

		override getInputs() {
			return new ArrayList(inputs.values())
		}

		override getOutputs() {
			return new ArrayList(outputs.values())
		}

	}

}
