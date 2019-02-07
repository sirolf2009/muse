package com.sirolf2009.muse

import com.sirolf2009.muse.interfaces.IChain
import com.sirolf2009.muse.interfaces.IConnectable
import com.sirolf2009.muse.interfaces.IInput
import com.sirolf2009.muse.interfaces.IOutput
import java.util.ArrayList
import java.util.List
import com.sirolf2009.muse.interfaces.IConnection

class AbstractChain extends AbstractConnectable implements IChain {
	
	val List<IConnectable> connectables
	val List<IConnection> connections
	
	new() {
		connectables = new ArrayList()
		connections = new ArrayList()
	}
	
	override getConnectables() {
		return connectables
	}
	
	override addConnectable(IConnectable connectable) {
		connectables.add(connectable)
	}
	
	override connect(IInput input, IOutput output) {
		val connection = input.connect(output)
		connections.add(connection)
		return connection
	}
	
	override getInputs() {
		return #[]
	}
	
	override getOutputs() {
		return #[]
	}
	
}