package com.sirolf2009.muse.interfaces

import com.sirolf2009.muse.AbstractConnectable
import com.sirolf2009.muse.SubjectConnector
import io.reactivex.Observable
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.PublishSubject
import java.util.Collections
import java.util.Date
import java.util.concurrent.TimeUnit

class DeleteMe {

	def static void main(String[] args) {
		val supplier = new SimpleSupplier()
		val converter = new SimpleConverter()
		val consumer = new SimpleConsumer()

		println("Connecting")
		supplier.getOutputs().get(0).getData().subscribe(converter.getInputs().get(0).getObserver())
		converter.getOutputs().get(0).getData().subscribe(consumer.getInputs().get(0).getObserver())

		Thread.sleep(8000)
	}

	static class SimpleSupplier extends AbstractConnectable {
		
		val output = new IConnector<Long>() {

			val observable = Observable.interval(1, TimeUnit.SECONDS).map[System.currentTimeMillis()].subscribeOn(Schedulers.io())

			override getData() {
				return observable
			}
			
			override getObserver() {
				return null
			}

			override getConnectable() {
				return SimpleSupplier.this
			}

		}

		override toString() {
			return getClass().getSimpleName()
		}

		override getInputs() {
			return Collections.EMPTY_LIST
		}

		override getOutputs() {
			return #[output]
		}

	}

	static class SimpleConsumer extends AbstractConnectable {

		
		val input = new SubjectConnector(this, PublishSubject.<Date>create())

		new() {
			input.getData().subscribe [
				println(it)
			]
		}

		override getInputs() {
			return #[input]
		}

		override getOutputs() {
			return #[]
		}
		
		override toString() {
			return getClass().getSimpleName()
		}
		
	}

	static class SimpleConverter extends AbstractConnectable {

		val IConnector<Long> input
		val IConnector<Date> output

		new() {
			input = new SubjectConnector(this, PublishSubject.<Long>create()) 
			output = new SubjectConnector(this, PublishSubject.<Date>create())
			input.getData().map[new Date(it)].subscribe(output.getObserver())
		}

		override getInputs() {
			return #[input]
		}

		override getOutputs() {
			return #[output]
		}

		override toString() {
			return getClass().getSimpleName()
		}

	}
}
