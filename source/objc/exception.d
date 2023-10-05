module objc.exception;

import objc;

extern(C) nothrow{
	alias objc_exception_preprocessor = NonNull!id function(NonNull!id exception);
	alias objc_exception_matcher = int function(NonNull!Class catch_type, NonNull!id exception);
	alias objc_uncaught_exception_handler = void function(id exception);
	alias objc_exception_handler = void function(Nullable!id unused, Nullable!(void*) context);
}

extern(C) nothrow @nogc{
	@available(macos: 10.5, ios: 2.0, tvos: 9.0, watchos: 1.0){
		/**
		Throw a runtime exception.
		This function is inserted by the compiler where `@throw` would otherwise be.
		
		Params
			exception = The exception to be thrown.
		*/
		noreturn objc_exception_throw(NonNull!id exception);
		
		noreturn objc_exception_rethrow();
		
		NonNull!id objc_begin_catch(NonNull!(void*) exc_buf);
		
		void objc_end_catch();
	}
	
	@available(macos: 10.8, ios: 6.0, tvos: 9.0, watchos: 1.0)
	noreturn objc_terminate();
	
	@available(10.5, 2.0, 9.0, 1.0, 2.0){
		NonNull!objc_exception_preprocessor objc_setExceptionPreprocessor(NonNull!objc_exception_preprocessor fn);
		
		NonNull!objc_exception_matcher objc_setExceptionMatcher(NonNull!objc_exception_matcher fn);
		
		NonNull!objc_uncaught_exception_handler objc_setUncaughtExceptionHandler(NonNull!objc_uncaught_exception_handler fn);
	}
}
