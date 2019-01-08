package com.sirolf2009.muse.interfaces

import java.util.List

/**
 * Some thing that can connect with other IConnectable's
 * As rxjava is push based, a target connects to a source's observable
 * +-----+       +-----+
 * |     |       |     |
 * |  A  | ----> |  B  |
 * |     |       |     |
 * +-----+       +-----+
 * Is read as: A connects to B, but data flows from B to A
 */
interface IConnectable extends IOperator {
	
	def boolean canConnectTo(IOutput<?> connectable)
	def void connectTo(IOutput<?> connectable)
	def List<? super IOutput<?>> getConnected()
	def disconnectFrom(IOutput<?> output) {
		if(!isConnectedTo(output)) {
			throw new IllegalArgumentException('''Can not disconnect from something that I'm not connected to''')
		}
		getConnected().remove(output)
		onChainBroken(output)
	}
	def isConnectedTo(IOutput<?> output) {
		return getConnected().contains(output)
	}
	
	/*
	 * TODO
	 * say you have 
	 * source -> map1 -> map2 -> sink
	 * and the connection between source and map1 gets broken;
	 * The sink should now dispose his Disposable
	 * map1 and map2 should clear their in-mem observables
	 * 
	 * say you have
	 * source1 -> map1 -v
	 *                  combineLatest -> sink
	 * source2 -> map2 -^
	 * and the connection between source and map1 gets broken;
	 * The sink should still dispose his Disposable
	 * map1 and combineLatest should clear their in-mem observables
	 * 
	 * So we need to notify everyone in the chain after the break point
	 */
	 /**
	  * gets triggered when the chain is broken
	  * @param connectable - the output from where the connection broke
	  */
	def void onChainBroken(IOutput<?> connectable)
	
}