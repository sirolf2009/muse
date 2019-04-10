package com.sirolf2009.muse.actorgraph

import java.io.Serializable
import java.util.function.Supplier
import javafx.scene.Node
import org.eclipse.xtend.lib.annotations.Data

@Data class InspectionResponse implements Serializable {
	
	val Supplier<Node> inspection
	
}