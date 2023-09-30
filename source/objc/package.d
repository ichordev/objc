module objc;

public import
	objc.message,
	objc.nsobject,
	objc.runtime;

///A UDA for optional Objective-C class methods.
enum optional;

///An opaque type that represents an Objective-C class.
struct objc_class;
alias Class = objc_class*;

///Represents an instance of a class.
struct objc_object{
	deprecated Class isa; ///(non-null)
}

///A pointer to an instance of a class.
alias id = objc_object*;

///An opaque type that represents a method selector.
struct objc_selector;
alias SEL = objc_selector*;

/**
A pointer to the function of a method implementation.
The parameters must be non-null.

Returns: (nullable)
*/
alias IMP = extern(C) id function(id, SEL, ...) nothrow;

///Zone support
struct _malloc_zone_t;
alias objc_zone_t = _malloc_zone_t*;

/**
Returns the class name of a given object.

Params:
	obj = (nullable) An Objective-C object.

Returns: (non-null) The name of the class of which obj is an instance.
*/
extern(C) const(char)* object_getClassName(id obj) nothrow @nogc;

/**
Returns a pointer to any extra bytes allocated with an instance given object.

Params:
	obj = (nullable) An Objective-C object.

Returns: (nullable) A pointer to any extra bytes allocated with `obj`. If `obj` was not allocated with any extra bytes, then dereferencing the returned pointer is undefined.

Note: This function returns a pointer to any extra bytes allocated with the instance (as specified by `class_createInstance` with extraBytes>0). This memory follows the object's ordinary ivars, but may not be adjacent to the last ivar.

Note: The returned pointer is guaranteed to be pointer-size aligned, even if the area following the object's last ivar is less aligned than that. Alignment greater than pointer-size is never guaranteed, even if the area following the object's last ivar is more aligned than that.

Note: In a garbage-collected environment, the memory is scanned conservatively.
*/
extern(C) void* object_getIndexedIvars(id obj) nothrow @nogc;

/**
Identifies a selector as being valid or invalid.

Params:
	sel = (non-null) The selector you want to identify.

Returns: `true` if selector is valid and has a function implementation, `false` otherwise.

Warning: On some platforms, an invalid reference (to invalid memory addresses) can cause a crash.
*/
extern(C) bool sel_isMapped(SEL sel) nothrow @nogc;

/**
Registers a method name with the Objective-C runtime system.

Params:
	str = (non-null) A pointer to a C string. Pass the name of the method you wish to register.

Returns: (non-null) A pointer of type SEL specifying the selector for the named method.

Note: The implementation of this method is identical to the implementation of `sel_registerName`.

Note: Prior to OS X version 10.0, this method tried to find the selector mapped to the given name and returned `null` if the selector was not found.
This was changed for safety, because it was observed that many of the callers of this function did not check the return value for `null`.
*/
extern(C) SEL sel_getUid(const(char)* str) nothrow @nogc;

alias objc_objectptr_t = const(void)*;
