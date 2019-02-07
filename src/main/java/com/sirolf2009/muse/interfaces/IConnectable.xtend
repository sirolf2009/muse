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
 * 
 * The sink is an IInput
 * The source is an IOutput
 * 
 * TODO
 * the connecting isn't quite figured out. 
 * We have a connectable with a list of IOutputs it's connected to.
 * We also have an output that gives an Observable and an input that takes it.
 * 
 * assuming only run-time for now, when a sink connects to a source:
 *  - the sinks input should know it's connected to the sources output
 *  - the sinks input should be called with the sources output
 *  -- if the sink is an IConsumer, it should also keep his subscription around somewhere
 * when the sink disconnects from the source:
 *  - the sink should know it's no longer connected to the source
 *  - the sinks getDisconnects should fire
 *  - the sinks and its childrens getUpstreamDisconnects should fire
 *  -- if the sink is an IConsumer, it should dispose his subscription
 *  -- if the sink isn't an IConsumer, but has IConsumers somewhere down the graph, they should dispose
 *  --- this is done via the upstreamDisconnects
 * 
 * Step 1
 *  +------------------+-----------------------------------+         +--+----------------------------------------+--+         +--+----+
 *  |                  | BehaviorSubject<Observable<Long>> |         |  | input.subscribe.cast(Long).map[it * 2] |  |         |  |    |
 *  | Observable<Long> +-----------------------------------+         +--+                                        +--+         +--+    |
 *  |                  |                                                |                                        |               |    |
 *  +------------------+                                                +----------------------------------------+               +----+
 * 
 * 
 * Step 2 
 *  +------------------+-----------------------------------+         +--+----------------------------------------+--+         +--+----+
 *  |                  | BehaviorSubject<Observable<Long>> |=========|  | input.subscribe.cast(Long).map[it * 2] |  |         |  |    |
 *  | Observable<Long> +-----------------------------------+         +--+                                        +--+         +--+    |
 *  |                  |                                                |                                        |               |    |
 *  +------------------+                                                +----------------------------------------+               +----+
 * 
 *  +----+--+         +--+----+--+         +--+----+
 *  |    |  |=========|  |    |  |=========|  |    |
 *  |    +--+         +--+    +--+         +--+    |
 *  |    |  |            |    |               |    |
 *  +----+--+            +----+               +----+
 * 
 * 
 * 
 * What if we just don't disconnect?
 * What we're currently building is the runtime I guess (note to self, make an overview of what is runtime and what is compile time).
 * During runtime, connections don't disconnect. All we need, is some sort of class that can be started
 */
interface IConnectable extends IOperator {
	
	def List<IConnector> getInputs()
	def List<IConnector> getOutputs()

}