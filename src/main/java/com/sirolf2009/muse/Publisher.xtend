package com.sirolf2009.muse

import java.util.function.Supplier
import io.reactivex.Observable

interface Publisher<T> extends Supplier<Observable<T>> {
	
}