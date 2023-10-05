module objc.message;

import objc;
import objc.runtime;

///Specifies the superclass of an instance.
struct objc_super{
	///(non-null) Specifies an instance of a class.
	id receiver;
	
	///(non-null) Specifies the particular superclass of the instance to message.
	Class super_class;
	
	/* super_class is the first class to search*/
}

/**
Sends a message with a simple return value to an instance of a class.

Params:
	self = (nullable) A pointer to the instance of the class that is to receive the message.
	op = (non-null) The selector of the method that handles the message.
	... = A variable argument list containing the arguments to the method.

Returns: (nullable) The return value of the method.

Note: When it encounters a method call, the compiler generates a call to one of the functions `objc_msgSend`, `objc_msgSend_stret`, `objc_msgSendSuper`, or `objc_msgSendSuper_stret`.
Messages sent to an object’s superclass (using the `super` keyword) are sent using `objc_msgSendSuper`; other messages are sent using `objc_msgSend`.
Methods that have data structures as return values are sent using `objc_msgSendSuper_stret` and `objc_msgSend_stret`.
*/
extern(C) id objc_msgSend(id self, SEL op, ...) nothrow @nogc;

/**
Sends a message with a simple return value to the superclass of an instance of a class.

Params:
	super = (non-null) A pointer to an \c objc_super data structure. Pass values identifying the context the message was sent to, including the instance of the class that is to receive the message and the superclass at which to start searching for the method implementation.
	op = (non-null) A pointer of type SEL. Pass the selector of the method that will handle the message.
	... = A variable argument list containing the arguments to the method.

Returns: (nullable) The return value of the method identified by \e op.

See: objc_msgSend
*/
extern(C) id objc_msgSendSuper(objc_super* super_, SEL op, ...) nothrow @nogc;

/*
Struct-returning Messaging Primitives

Use these functions to call methods that return structs on the stack.
On some architectures, some structures are returned in registers.
Consult your local function call ABI documentation for details.

These functions must be cast to an appropriate function pointer type
before being called.
*/

version(AArch64){
	alias objc_msgSend_stret = objc_msgSend;
	alias objc_msgSendSuper_stret = objc_msgSend;
}else{
	/**
	Sends a message with a data-structure return value to an instance of a class.
	
	See: objc_msgSend
	*/
	extern(C) void objc_msgSend_stret(id self, SEL op, ...) nothrow @nogc;
	
	/**
	Sends a message with a data-structure return value to the superclass of an instance of a class.
	
	@see objc_msgSendSuper
	*/
	extern(C) void objc_msgSendSuper_stret(objc_super* super_, SEL op, ...) nothrow @nogc;
}


/*
Floating-point-returning Messaging Primitives

Use these functions to call methods that return floating-point values 
on the stack. 
Consult your local function call ABI documentation for details.

arm:    objc_msgSend_fpret not used
i386:   objc_msgSend_fpret used for `float`, `double`, `long double`.
x86-64: objc_msgSend_fpret used for `long double`.

arm:    objc_msgSend_fp2ret not used
i386:   objc_msgSend_fp2ret not used
x86-64: objc_msgSend_fp2ret used for `_Complex long double`.

These functions must be cast to an appropriate function pointer type 
before being called. 
*/

version(X86){
/**
	Sends a message with a floating-point return value to an instance of a class.
	
	See: objc_msgSend
	
	Note: On the i386 platform, the ABI for functions returning a floating-point value is incompatible with that for functions returning an integral type.
	On the i386 platform, therefore, you must use `objc_msgSend_fpret` for functions returning non-integral type. For `float` or `real` return types, cast the function to an appropriate function pointer type first.
	*/
	extern(C) double objc_msgSend_fpret(id self, SEL op, ...) nothrow @nogc;

}else version(X86_64){
	/**
	Sends a message with a floating-point return value to an instance of a class.
	
	See: objc_msgSend
	*/
	extern(C) real objc_msgSend_fpret(id self, SEL op, ...) nothrow @nogc;
	
	extern(C) void objc_msgSend_fp2ret(id self, SEL op, ...) nothrow @nogc;
	
}
/* Use objc_msgSendSuper() for fp-returning messages to super.*/
/* See also objc_msgSendv_fpret() below.*/

template msgSendFloatRet(T){
	version(X86){
		alias msgSendFloatRet = objc_msgSend_fpret;
	}else version(X86_64){
		static if(is(T == real)){
			alias msgSendFloatRet = objc_msgSend_fpret;
		}else{
			alias msgSendFloatRet = objc_msgSend;
		}
	}else{
		alias msgSendFloatRet = objc_msgSend;
	}
}


/*
Direct Method Invocation Primitives
Use these functions to call the implementation of a given Method.
This is faster than calling method_getImplementation() and method_getName().

The receiver must not be nil.

These functions must be cast to an appropriate function pointer type before being called.
*/

/**
Params:
	receiver = (nullable)
	m = (non-null)

Returns: (nullable)
*/
extern(C) id method_invoke(id receiver, Method m, ...) nothrow @nogc;

version(AArch64){
	alias method_invoke_stret = method_invoke;
}else{
	 /**
	Params:
		receiver = (nullable)
		m = (non-null)
	*/
	extern(C) void method_invoke_stret(id receiver, Method m, ...) nothrow @nogc;
}


/*
Message Forwarding Primitives
Use these functions to forward a message as if the receiver did not respond to it.

The receiver must not be `nil`.

`class_getMethodImplementation` may return `(IMP)_objc_msgForward`.
`class_getMethodImplementation_stret` may return `(IMP)_objc_msgForward_stret`.

These functions must be cast to an appropriate function pointer type before being called.

Before Mac OS X 10.6, `_objc_msgForward` must not be called directly but may be compared to other `IMP` values.
*/

/**
Params:
	receiver = (non-null)
	sel = (non-null)

Returns: (nullable)
*/
extern(C) id _objc_msgForward(id receiver, SEL sel, ...) nothrow @nogc;

version(AArch64){
	alias _objc_msgForward_stret = _objc_msgForward;
}else{
	/**
	Params:
		receiver = (non-null)
		sel = (non-null)
	*/
	extern(C) void _objc_msgForward_stret(id receiver, SEL sel, ...) nothrow @nogc;
}

enum makeMethod = (string retnType, string iden, string sel, string args){
	string sendFn = (){
		if(retnType[$-1] == '*') return "objc_msgSend";
		if(retnType == "float" || retnType == "double" || retnType == "real") return "msgSendFloatRet!"~retnType;
		return "objc_msgSend_stret";
	}();
	sel = sel.length && sel[0] != ':' ? sel : iden~sel;
	
	string ret = retnType~" "~iden~"("~args~") nothrow @nogc{";
	ret ~= "\n\talias _Fn = extern(C) "~retnType~" function(typeof(this)*, SEL, "~args~") nothrow @nogc;";
	ret ~= (retnType == "void" ? "\n\t" : "\n\treturn ") ~ "(cast(_Fn)&"~sendFn~")(&this, getSEL!`"~sel~"`, __traits(parameters));";
	ret ~= "\n}";
	return ret;
};

enum makeStaticMethod = (string retnType, string iden, string sel, string args){
	string sendFn = (){
		if(retnType[$-1] == '*') return "objc_msgSend";
		if(retnType=="float" || retnType=="double" || retnType=="real") return "msgSendFloatRet!"~retnType;
		return "objc_msgSend_stret";
	}();
	sel = sel.length && sel[0] != ':' ? sel : iden~sel;
	
	string ret = "static "~retnType~" "~iden~"("~args~") nothrow @nogc{";
	ret ~= "\n\talias _Fn = extern(C) "~retnType~" function(Class, SEL, "~args~") nothrow @nogc;";
	ret ~= (retnType == "void" ? "\n\t" : "\n\treturn ") ~ "(cast(_Fn)&"~sendFn~")(getClass!(__traits(identifier, typeof(this))), getSEL!`"~sel~"`, __traits(parameters));";
	ret ~= "\n}";
	return ret;
};

enum makeProperty = (string type, string iden){
	string setSendFn = (){
		if(type[$-1] == '*') return "objc_msgSend";
		if(type=="float" || type=="double" || type=="real") return "msgSendFloatRet!"~type;
		return "objc_msgSend_stret";
	}();
	string setSel = "set" ~ (iden[0]>='a' && iden[0]<='z' ? cast(char)(iden[0]-('a'-'A')) : iden[0]) ~ iden[1..$] ~ ':';
	
	string ret = "@property "~type~" "~iden~"() nothrow @nogc{";
	ret ~= "\n\talias _Fn = extern(C) "~type~" function(typeof(this)*, SEL) nothrow @nogc;";
	ret ~= "\n\treturn (cast(_Fn)&objc_msgSend)(&this, getSEL!`"~iden~"`);";
	ret ~= "\n}";
	ret ~= "\n@property void "~iden~"("~type~" val) nothrow @nogc{";
	ret ~= "\n\talias _Fn = extern(C) void function(typeof(this)*, SEL, "~type~") nothrow @nogc;";
	ret ~= "\n\treturn (cast(_Fn)&"~setSendFn~")(&this, getSEL!`"~setSel~"`, val);";
	ret ~= "\n}";
	return ret;
};
