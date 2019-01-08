package com.sirolf2009.muse.interfaces

import java.lang.reflect.ParameterizedType

/**
 * Some thing that takes something
 */
interface IConsumer<T> extends IConnectable, IInput<T> {
	
	override canConnectTo(IOutput<?> connectable) {
		return connectable.getOutputType().equals(getInputType())
	}
	
	override getInputType() {
		getClass().getGenericInterfaces().filter[
			getTypeName().startsWith("com.sirolf2009.muse.interfaces.IConsumer")
		].map[
			it as ParameterizedType
		].map[
			getActualTypeArguments().get(0)
		].get(0) as Class<T>
	}
	
}