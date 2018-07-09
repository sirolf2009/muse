package com.sirolf2009.muse.core.model

import org.eclipse.xtend.lib.annotations.Data

@Data class Connection<A, B> implements IConnection<A, B> {
	
	val IComponent<A> source
	val IComponent<B> target
	
}