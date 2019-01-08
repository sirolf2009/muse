package com.sirolf2009.muse.interfaces

import java.lang.reflect.ParameterizedType
import java.util.Collections

/**
 * Some thing that yields something
 */
interface ISupplier<T> extends IConnectable, IOutput<T> {

	override canConnectTo(IOutput<?> connectable) {
		return false
	}
	
	override connectTo(IOutput<?> connectable) {
		throw new RuntimeException("Suppliers cannot connect to things")
	}
	
	override getConnected() {
		return Collections.EMPTY_LIST
	}

	override getOutputType() {
		println(getClass().getGenericInterfaces().filter[getTypeName().startsWith("com.sirolf2009.muse.interfaces.ISupplier")])
		getClass().getGenericInterfaces().filter[
			getTypeName().startsWith("com.sirolf2009.muse.interfaces.ISupplier")
		].map[
			it as ParameterizedType
		].map[
			getActualTypeArguments().get(0)
		].get(0) as Class<T>
	}

}
