package com.sirolf2009.muse.extensions

import akka.actor.ActorPath
import java.util.List

class ActorPathExtensions {
	
	def static isUser(ActorPath path) {
		return path.startsWith(#["user"])
	}
	
	def static startsWith(ActorPath path, List<String> segments) {
		if(path.getElements().size() < segments.size()) {
			return false
		}
		val mismatch = (0 ..< segments.size()).findFirst[!path.getElements().get(it).equals(segments.get(it))]
		return mismatch === null
	}
	
}