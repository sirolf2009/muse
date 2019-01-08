package com.sirolf2009.muse.interfaces

import java.lang.reflect.ParameterizedType

/**
 * Some thing that converts something into something else 
 */
interface IConverter<I, O> extends IConnectable, IInput<I>, IOutput<O> {

	override canConnectTo(IOutput<?> output) {
		output.getOutputType().equals(getOutputType())
	}

	override getInputType() {
		getClass().getGenericInterfaces().filter[
			getTypeName().startsWith("com.sirolf2009.muse.interfaces.IConverter")
		].map[
			it as ParameterizedType
		].map[
			getActualTypeArguments().get(0)
		].get(0) as Class<I>
	}

	override getOutputType() {
		getClass().getGenericInterfaces().filter[
			getTypeName().startsWith("com.sirolf2009.muse.interfaces.IConverter")
		].map[
			it as ParameterizedType
		].map[
			getActualTypeArguments().get(0)
		].get(0) as Class<O>
	}

}
