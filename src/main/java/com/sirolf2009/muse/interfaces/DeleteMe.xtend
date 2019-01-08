package com.sirolf2009.muse.interfaces

import groovy.lang.GroovyShell
import io.reactivex.Observable
import io.reactivex.schedulers.Schedulers
import java.text.SimpleDateFormat
import java.util.ArrayList
import java.util.Date
import java.util.List
import java.util.concurrent.TimeUnit
import io.reactivex.disposables.Disposable

class DeleteMe {

	def static void main(String[] args) {
		val supplier = new GroovySupplier()
		val converter = new SimpleConverter()
		val consumer = new SimpleConsumer()

		println("Connecting")
		converter.connectTo(supplier)
		consumer.connectTo(converter)
		Thread.sleep(8000)
		
		println("Disconnecting")
		consumer.disconnectFrom(converter)
		Thread.sleep(2000)
		
		println("Reconnecting")
		consumer.connectTo(converter)
		Thread.sleep(8000)
	}

	static class SimpleSupplier implements ISupplier<Long> {

		val List<? super IOutput<?>> connections = new ArrayList()

		override connectTo(IOutput<?> connectable) {
			connections.add(connectable)
		}

		override getConnected() {
			return connections
		}

		override xProperty() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override yProperty() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override widthProperty() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override heightProperty() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override getOutput() {
			return Observable.interval(1, TimeUnit.SECONDS).map[System.currentTimeMillis()].subscribeOn(Schedulers.io())
		}
		
		override onChainBroken(IOutput<?> connectable) {
			// I'm a supplier, I don't do anything
		}

	}

	/*
	 * TODO 
	 * what if the user changes this from Observable<Long> to Observable<String>?
	 * We don't want to break the connection chain on edit, because the user might change from Observable<Long> to a different Observable<Long> and you don't want to reconnect everything on edit.
	 * So on edit, we should check every connection to me and check canConnectTo, if that returns false, break the chain.
	 * 
	 * options:
	 *  - we can propagate a validate event down the chain
	 *    - we need to have that chain though, currently we know who we're connected to, but not if they've changed
	 *      - on every connect, duplicate the chain of the node we're connecting to and append us?
	 *        - would also be a nice debugging tool
	 *  - we can keep a reference of people connected to us and trigger their check
	 *    - we already have lists of people we're connected to. At some point it will happen that 2 nodes disagree if they're connected to eachother
	 *      - we can't make the disposable the deciding factor for connections, because a map operation yields an observable, not a disposable 
	 * 
	 */
	static class GroovySupplier implements ISupplier<Long> {

		val List<? super IOutput<?>> connections = new ArrayList()
		val String groovyCode = '''io.reactivex.Observable.interval(1, java.util.concurrent.TimeUnit.SECONDS).map { System.currentTimeMillis() }'''
		val shell = new GroovyShell()

		override connectTo(IOutput<?> connectable) {
			connections.add(connectable)
		}

		override getConnected() {
			return connections
		}

		override xProperty() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override yProperty() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override widthProperty() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override heightProperty() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override getOutput() {
			return shell.evaluate(groovyCode) as Observable<Long>
		}
		
		override onChainBroken(IOutput<?> connectable) {
			// I'm a supplier, I don't do anything
		}

	}

	static class SimpleConverter implements IConverter<Long, String> {

		val List<? super IOutput<?>> connections = new ArrayList()
		var Observable<String> output

		override connectTo(IOutput<?> connectable) {
			connections.add(connectable)
			connect(connectable.getOutput() as Observable<Long>)
		}

		override getConnected() {
			return connections
		}

		override xProperty() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override yProperty() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override widthProperty() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override heightProperty() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override getOutput() {
			output
		}

		override connect(Observable<Long> observable) {
			output = observable.map[new Date(it)].map[new SimpleDateFormat("HH:mm:ss").format(it)]
		}
		
		override onChainBroken(IOutput<?> connectable) {
			if(isConnectedTo(connectable)) {
				connections.remove(connectable)
			}
			output = null
		}

	}

	static class SimpleConsumer implements IConsumer<String> {

		val List<? super IOutput<?>> connections = new ArrayList()
		var Disposable disposable

		override getConnected() {
			return connections
		}

		override xProperty() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override yProperty() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override widthProperty() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override heightProperty() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override connectTo(IOutput<?> connectable) {
			connections.add(connectable)
			connect(connectable.getOutput() as Observable<String>)
		}

		override connect(Observable<String> observable) {
			if(disposable !== null) {
				disposable.dispose()
			}
			disposable = observable.subscribe [
				println(it)
			]
		}
		
		override onChainBroken(IOutput<?> connectable) {
			if(isConnectedTo(connectable)) {
				connections.remove(connectable)
			}
			disposable.dispose()
			disposable = null
		}

	}

}
