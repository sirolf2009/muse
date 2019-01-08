package com.sirolf2009.muse.interfaces

/**
 * A chain is a directed tree of connected IConnectable.
 * 
 * It may look like:
 * source -> map1 -> map2 -> sink
 * 
 * Or like:
 * source1 -> map1 -v
 *                  combineLatest -> sink
 * source2 -> map2 -^
 * 
 * Or like:
 *                  map2 -> sink1 
 * source1 -> map1 -v^
 *                  map3 -> sink2
 * 
 * Maybe also the following 3 (would allow for nice code reusing):
 * source -> map
 * map -> sink
 * map
 * 
 */
interface IChain {
	
}