package com.sirolf2009.muse

import io.reactivex.Flowable
import java.lang.reflect.Type
import java.util.List

abstract class MNode {
	
	def List<Type> inputs()
	def List<Flowable<?>> outputs()
	
}