module objc.runtime;

import objc;

//Types

version(D_LP64){
	alias NSInteger = long;
	alias NSUInteger = ulong;
}else{
	alias NSInteger = int;
	alias NSUInteger = uint;
}

///An opaque type that represents a method in a class definition.
struct objc_method;
alias Method = objc_method*;

///An opaque type that represents an instance variable.
struct objc_ivar;
alias Ivar = objc_ivar*;

///An opaque type that represents a category.
struct objc_category;
alias Category = objc_category*;

///An opaque type that represents an Objective-C declared property.
struct objc_property;
alias objc_property_t = objc_property*;

alias Protocol = objc_object;

///Defines a method
struct objc_method_description{
	SEL name; ///(nullable) The name of the method
	char* types; ///(nullable) The types of the method arguments
}

///Defines a property attribute
struct objc_property_attribute_t{
	const(char)* name; ///(non-null) The name of the attribute
	const(char)* value; ///(non-null) The value of the attribute (usually empty)
}


//Functions


//Working with Instances

/**
Returns the class of an object.

Params:
	obj = (nullable) The object you want to inspect.

Returns: (nullable) The class object of which `object` is an instance, or `Nil` if `object` is `nil`.
*/
extern(C) Class object_getClass(id obj) nothrow @nogc;
/**
Sets the class of an object.

Params:
	obj = (nullable) The object to modify.
	cls = (non-null) A class object.

Returns: (nullable) The previous value of `object`'s class, or `Nil` if `object` is `nil`.
*/
extern(C) Class object_setClass(id obj, Class cls) nothrow @nogc;
/**
Returns whether an object is a class object.

Params:
	obj = (nullable) An Objective-C object.

Returns: `true` if the object is a class or metaclass, `false` otherwise.
*/
extern(C) bool object_isClass(id obj) nothrow @nogc;
/**
Reads the value of an instance variable in an object.

Params:
	obj = (nullable) The object containing the instance variable whose value you want to read.
	ivar = (non-null) The Ivar describing the instance variable whose value you want to read.

Returns: (nullable) The value of the instance variable specified by `ivar`, or `nil` if `object` is `nil`.

Note: `object_getIvar` is faster than `object_getInstanceVariable` if the Ivar for the instance variable is already known.
*/
extern(C) id object_getIvar(id obj, Ivar ivar) nothrow @nogc;
/**
Sets the value of an instance variable in an object.

Params:
	obj = (nullable) The object containing the instance variable whose value you want to set.
	ivar = (non-null) The Ivar describing the instance variable whose value you want to set.
	value = (nullable) The new value for the instance variable.

Note: Instance variables with known memory management (such as ARC strong and weak) use that memory management.
Instance variables with unknown memory management are assigned as if they were unsafe_unretained.
Note: `object_setIvar` is faster than `object_setInstanceVariable` if the Ivar for the instance variable is already known.
*/
extern(C) void object_setIvar(id obj, Ivar ivar, id value) nothrow @nogc;
/**
Sets the value of an instance variable in an object.

Params:
	obj = (nullable) The object containing the instance variable whose value you want to set.
	ivar = (non-null) The Ivar describing the instance variable whose value you want to set.
	value = (nullable) The new value for the instance variable.

Note: Instance variables with known memory management (such as ARC strong and weak) use that memory management.
Instance variables with unknown memory management are assigned as if they were strong.
Note: `object_setIvar` is faster than `object_setInstanceVariable` if the Ivar for the instance variable is already known.
*/
extern(C) void object_setIvarWithStrongDefault(id obj, Ivar ivar, id value) nothrow @nogc;


//Obtaining Class Definitions

/**
Returns the class definition of a specified class.

Params:
	name = (non-null) The name of the class to look up.

Returns: (nullable) The `Class` object for the named class, or `nil` if the class is not registered with the Objective-C runtime.

Note: The implementation of `objc_getClass` is identical to the implementation of `objc_lookUpClass`.
*/
extern(C) Class objc_getClass(const(char)* name) nothrow @nogc;

/**
Returns the metaclass definition of a specified class.

Params:
	name = (non-null) The name of the class to look up.

Returns: (nullable) The `Class` object for the metaclass of the named class, or `nil` if the class is not registered with the Objective-C runtime.

Note: If the definition for the named class is not registered, this function calls the class handler callback and then checks a second time to see if the class is registered.
However, every class definition must have a valid metaclass definition, and so the metaclass definition is always returned, whether it’s valid or not.
*/
extern(C) Class objc_getMetaClass(const(char)* name) nothrow @nogc;

/**
Returns the class definition of a specified class.

Params:
	name = (non-null) The name of the class to look up.

Returns: (nullable) The `Class` object for the named class, or `nil` if the class is not registered with the Objective-C runtime.

Note: The implementation of `objc_lookUpClass` is identical to the implementation of `objc_getClass`.
*/
extern(C) Class objc_lookUpClass(const(char)* name) nothrow @nogc;

/**
Returns the class definition of a specified class.

Params:
	name = (non-null) The name of the class to look up.

Returns: (non-null) The Class object for the named class.

Note: This function is the same as `objc_getClass`, but kills the process if the class is not found.
*/
extern(C) Class objc_getRequiredClass(const(char)* name) nothrow @nogc;
/**
Obtains the list of registered class definitions.

Params:
	buffer = An array of `Class` values. On output, each `Class` value points to one class definition, up to either `bufferCount` or the total number of registered classes, whichever is less.
		You can pass `null` to obtain the total number of registered class definitions without actually retrieving any class definitions.
	bufferCount = An integer value. Pass the number of pointers for which you have allocated space in `buffer`. On return, this function fills in only this number of elements.
		If this number is less than the number of registered classes, this function returns an arbitrary subset of the registered classes.

Returns: (nullable pointer to non-nulll `Class`) An integer value indicating the total number of registered classes.

Note: The Objective-C runtime library automatically registers all the classes defined in your source code.
You can create class definitions at runtime and register them with the `objc_addClass` function.

Warning: You cannot assume that class objects you get from this function are classes that inherit from `NSObject`,
so you cannot safely call any methods on such classes without detecting that the method is implemented first.
*/
extern(C) int objc_getClassList(Class* buffer, int bufferCount) nothrow @nogc;

/**
Creates and returns a list of pointers to all registered class definitions.

Params:
	outCount = (nullable) An integer pointer used to store the number of classes returned by this function in the list.

Returns: (nullable pointer to non-null `Class`) A nil-terminated array of classes. It must be freed with `free`.

See: `objc_getClassList`
*/
extern(C) Class* objc_copyClassList(uint* outCount) nothrow @nogc;

enum const(void)* OBJC_DYNAMIC_CLASSES = cast(const(void)*)-1;

/**
Enumerates classes, filtering by image, name, protocol conformance and superclass.

Params:
	image = (nullable) The image to search. Can be
			- `null` (search the caller's image);
			- `OBJC_DYNAMIC_CLASSES` (search dynamically registered classes);
			- a handle returned by `dlopen`(3), or the Mach header of an image loaded into the current process.
	namePrefix = (nullable) If non-`null`, a required prefix for the class name.
	conformingTo = (nullable) If non-`null`, a protocol to which the enumerated classes must conform.
	subclassing = (nullable) If non-`null`, a class which the enumerated classes must subclass.
	block = (non-null) A block that is called for each matching class. Can abort enumeration by setting `*stop` to `true`.
*/
extern(C) void objc_enumerateClasses(const(void)* image, const(char)* namePrefix, Protocol* conformingTo, Class subclassing, scope void delegate(Class aClass /*(non-null)*/, bool* stop /*(non-null)*/) block /*(non-null)*/) nothrow @nogc;


//Working with Classes

/**
Returns the name of a class.

Params:
	cls = (nullable) A class object.

Returns: (non-null) The name of the class, or the empty string if `cls` is `Nil`.
*/
extern(C) const(char)* class_getName(Class cls) nothrow @nogc;

/**
Returns a Boolean value that indicates whether a class object is a metaclass.

Params:
	cls = (nullable) A class object.

Returns: `true` if `cls` is a metaclass, `false` if `cls` is a non-meta class,  `false` if `cls` is `Nil`.
*/
extern(C) bool class_isMetaClass(Class cls) nothrow @nogc;

/**
Returns the superclass of a class.

Params:
	cls = (nullable) A class object.

Returns: (nullable) The superclass of the class, or `Nil` if `cls` is a root class, or `Nil` if `cls` is `Nil`.

Note: You should usually use `NSObject`'s `superclass` method instead of this function.
*/
extern(C) Class class_getSuperclass(Class cls) nothrow @nogc;

/**
Returns the version number of a class definition.

Params:
	cls = (nullable) A pointer to a `Class` data structure. Pass the class definition for which you wish to obtain the version.

Returns: An integer indicating the version number of the class definition.

See: `class_setVersion`
*/
extern(C) int class_getVersion(Class cls) nothrow @nogc;

/**
Sets the version number of a class definition.

Params:
	cls = (nullable) A pointer to a `Class` data structure. Pass the class definition for which you wish to set the version.
	version_ = An integer. Pass the new version number of the class definition.

Note: You can use the version number of the class definition to provide versioning of the interface that your class represents to other classes.
This is especially useful for object serialization (that is, archiving of the object in a flattened form),
where it is important to recognise changes to the layout of the instance variables in different class-definition versions.

Note: Classes derived from the Foundation framework `NSObject` class can set the class-definition version number using the `setVersion:` class method,
which is implemented using the `class_setVersion` function.
*/
extern(C) void class_setVersion(Class cls, int version_) nothrow @nogc;

/**
Returns the size of instances of a class.

Params:
	cls = (nullable) A class object.

Returns: The size in bytes of instances of the class `cls`, or `0` if `cls` is `Nil`.
*/
extern(C) size_t class_getInstanceSize(Class cls) nothrow @nogc;

/**
Returns the `Ivar` for a specified instance variable of a given class.

Params:
	cls = (nullable) The class whose instance variable you wish to obtain.
	name = (non-null) The name of the instance variable definition to obtain.

Returns: (nullable) A pointer to an `Ivar` data structure containing information about the instance variable specified by `name`.
*/
extern(C) Ivar class_getInstanceVariable(Class cls, const(char)* name) nothrow @nogc;

/**
Returns the Ivar for a specified class variable of a given class.

Params:
	cls = (nullable) The class definition whose class variable you wish to obtain.
	name = (non-null) The name of the class variable definition to obtain.

Returns: (nullable) A pointer to an `Ivar` data structure containing information about the class variable specified by `name`.
*/
extern(C) Ivar class_getClassVariable(Class cls, const(char)* name) nothrow @nogc;

/**
Describes the instance variables declared by a class.

Params:
	cls = (nullable) The class to inspect.
	outCount = (nullable) On return, contains the length of the returned array. If outCount is `null`, the length is not returned.

Returns: (nullable pointer to non-null `Ivar`) An array of pointers of type Ivar describing the instance variables declared by the class.
Any instance variables declared by superclasses are not included.
The array contains `*outCount` pointers followed by a `null` terminator. You must free the array with `free`.
If the class declares no instance variables, or `cls` is `Nil`, `null` is returned and `*outCount` is 0.
*/
extern(C) Ivar* class_copyIvarList(Class cls, uint* outCount) nothrow @nogc;

/**
Returns a specified instance method for a given class.

Params:
	cls = (nullable) The class you want to inspect.
	name = (non-null) The selector of the method you want to retrieve.

Returns: (nullable) The method that corresponds to the implementation of the selector specified by `name` for the class specified by `cls`,
or `null` if the specified class or its superclasses do not contain an instance method with the specified selector.

Note: This function searches superclasses for implementations, whereas `class_copyMethodList` does not.
*/
extern(C) Method class_getInstanceMethod(Class cls, SEL name) nothrow @nogc;

/**
Returns a pointer to the data structure describing a given class method for a given class.

Params:
	cls = (nullable) A pointer to a class definition. Pass the class that contains the method you want to retrieve.
	name = (non-null) A pointer of type `SEL`. Pass the selector of the method you want to retrieve.

Returns: (nullable) A pointer to the `Method` data structure that corresponds to the implementation of the selector
specified by aSelector for the class specified by aClass, or `null` if the specified class or its superclasses do not contain an instance method with the specified selector.

Note: Note that this function searches superclasses for implementations, whereas `class_copyMethodList` does not.
*/
extern(C) Method class_getClassMethod(Class cls, SEL name) nothrow @nogc;

/**
Returns the function pointer that would be called if a particular message were sent to an instance of a class.

Params:
	cls = (nullable) The class you want to inspect.
	name = (non-null) A selector.

Returns: (nullable) The function pointer that would be called if `[object name]` were called with an instance of the class, or `null` if `cls` is `Nil`.

Note: `class_getMethodImplementation` may be faster than `method_getImplementation(class_getInstanceMethod(cls, name))`.

Note: The function pointer returned may be a function internal to the runtime instead of an actual method implementation.
For example, if instances of the class do not respond to the selector, the function pointer returned will be part of the runtime's message forwarding machinery.
*/
extern(C) IMP class_getMethodImplementation(Class cls, SEL name) nothrow @nogc;

version(AArch64){
}else{
	/**
	Returns the function pointer that would be called if a particular message were sent to an instance of a class.
	
	Params:
		cls = (nullable) The class you want to inspect.
		name = (non-null) A selector.
	
	Returns: (nullable) The function pointer that would be called if `[object name]` were called with an instance of the class, or `null` if `cls` is `Nil`.
	*/
	extern(C) IMP class_getMethodImplementation_stret(Class cls, SEL name) nothrow @nogc;
}

/**
Returns a Boolean value that indicates whether instances of a class respond to a particular selector.

Params:
	cls = (nullable) The class you want to inspect.
	sel = (non-null) A selector.

Returns: `true` if instances of the class respond to the selector, otherwise `false`.

Note: You should usually use `NSObject`'s `respondsToSelector`: or `instancesRespondToSelector`: methods instead of this function.
*/
extern(C) bool class_respondsToSelector(Class cls, SEL sel) nothrow @nogc;

/**
Describes the instance methods implemented by a class.

Params:
	cls = (nullable) The class you want to inspect.
	outCount = (nullable) On return, contains the length of the returned array. If outCount is `null`, the length is not returned.

Returns: (nullable pointer to non-null `Method`) An array of pointers of type `Method` describing the instance methods implemented by the class—any instance methods implemented by superclasses are not included.
The array contains `*outCount` pointers followed by a `null` terminator. You must free the array with `free`. If cls implements no instance methods, or cls is Nil, returns `null` and `*outCount` is 0.

Note: To get the class methods of a class, use `class_copyMethodList(object_getClass(cls), &count)`.

Note: To get the implementations of methods that may be implemented by superclasses, use `class_getInstanceMethod` or `class_getClassMethod`.
*/
extern(C) Method* class_copyMethodList(Class cls, uint* outCount) nothrow @nogc;

/**
Returns a Boolean value that indicates whether a class conforms to a given protocol.

Params:
	cls = (nullable) The class you want to inspect.
	protocol = (nullable) A protocol.

Returns: `true` if cls conforms to protocol, otherwise `false`.

Note: You should usually use `NSObject`'s `conformsToProtocol:` method instead of this function.
*/
extern(C) bool class_conformsToProtocol(Class cls, Protocol* protocol) nothrow @nogc;

/**
Describes the protocols adopted by a class.

Params:
	cls = (nullable) The class you want to inspect.
	outCount = (nullable) On return, contains the length of the returned array. If outCount is `null`, the length is not returned.

Returns: (nullable pointer to non-null `Protocol` pointer) An array of pointers of type Protocol* describing the protocols adopted by the class. Any protocols adopted by superclasses or other protocols are not included. The array contains `*outCount` pointers followed by a `null` terminator. You must free the array with free().
If cls adopts no protocols, or cls is Nil, returns `null` and `*outCount` is `0`.
*/
extern(C) Protocol** class_copyProtocolList(Class cls, uint* outCount) nothrow @nogc;

/**
Returns a property with a given name of a given class.

Params:
	cls = (nullable) The class you want to inspect.
	name = (non-null) The name of the property you want to inspect.

Returns: (nullable) A pointer of type `objc_property_t` describing the property, or `null` if the class does not declare a property with that name, or `null` if `cls` is `Nil`.
*/
extern(C) objc_property_t class_getProperty(Class cls, const(char)* name) nothrow @nogc;

/**
Describes the properties declared by a class.

Params:
	cls = (nullable) The class you want to inspect.
	outCount = (nullable) On return, contains the length of the returned array. If `outCount` is `null`, the length is not returned.

Returns: (nullable pointer to non-null `objc_property_t`) An array of pointers of type `objc_property_t` describing the properties declared by the class.
Any properties declared by superclasses are not included. The array contains `*outCount` pointers followed by a `null` terminator. You must free the array with `free`.
If `cls` declares no properties, or `cls` is `Nil`, returns `null` and `*outCount` is `0`.
*/
extern(C) objc_property_t* class_copyPropertyList(Class cls, uint* outCount) nothrow @nogc;

/**
Returns a description of the `Ivar` layout for a given class.

Params:
	cls = (nullable) The class to inspect.

Returns: (nullable) A description of the `Ivar` layout for `cls`.
*/
extern(C) const(ubyte)* class_getIvarLayout(Class cls) nothrow @nogc;

/**
Returns a description of the layout of weak Ivars for a given class.

Params:
	cls = (nullable) The class to inspect.

Returns: (nullable) A description of the layout of the weak `Ivars` for `cls`.
*/
extern(C) const(ubyte)* class_getWeakIvarLayout(Class cls) nothrow @nogc;

/**
Adds a new method to a class with a given name and implementation.

Params:
	cls = (nullable) The class to which to add a method.
	name = (non-null) A selector that specifies the name of the method being added.
	imp = (non-null) A function which is the implementation of the new method. The function must take at least two arguments—self and _cmd.
	types = (nullable) An array of characters that describe the types of the arguments to the method.

Returns: `true` if the method was added successfully, otherwise `false` (for example, the class already contains a method implementation with that name).

Note: class_addMethod will add an override of a superclass's implementation, but will not replace an existing implementation in this class. To change an existing implementation, use method_setImplementation.
*/
extern(C) bool class_addMethod(Class cls, SEL name, IMP imp, const(char)* types) nothrow @nogc;

/**
Replaces the implementation of a method for a given class.

Params:
	cls = (nullable) The class you want to modify.
	name = (non-null) A selector that identifies the method whose implementation you want to replace.
	imp = (non-null) The new implementation for the method identified by name for the class identified by cls.
	types = (nullable) An array of characters that describe the types of the arguments to the method. Since the function must take at least two arguments—self and _cmd, the second and third characters must be “@:” (the first character is the return type).

Returns: (nullable) The previous implementation of the method identified by `name` for the class identified by `cls`.

Note: This function behaves in two different ways: - If the method identified by `name` does not yet exist, it is added as if `class_addMethod` were called.   The type encoding specified by `types` is used as given. - If the method identified by `name` does exist, its `IMP` is replaced as if `method_setImplementation` were called.   The type encoding specified by `types` is ignored.
*/
extern(C) IMP class_replaceMethod(Class cls, SEL name, IMP imp, const(char)* types) nothrow @nogc;

/**
Adds a new instance variable to a class.

Params:
	cls = (nullable)
	name = (non-null)
	size =
	alignment =
	types = (nullable)

Returns: `true` if the instance variable was added successfully, otherwise `false` (for example, the class already contains an instance variable with that name).

Note: This function may only be called after `objc_allocateClassPair` and before `objc_registerClassPair`.
Adding an instance variable to an existing class is not supported.

Note: The class must not be a metaclass. Adding an instance variable to a metaclass is not supported.

Note: The instance variable's minimum alignment in bytes is `1<<align`.
The minimum alignment of an instance variable depends on the ivar's type and the machine architecture.
For variables of any pointer type, pass `log2(pointer.typeof.sizeof)`.
*/
extern(C) bool class_addIvar(Class cls, const(char)* name, size_t size, ubyte alignment, const(char)* types) nothrow @nogc;

/**
Adds a protocol to a class.

Params:
	cls = (nullable) The class to modify.
	protocol = (non-null) The protocol to add to `cls`.

Returns: `true` if the method was added successfully, otherwise `false` (for example, the class already conforms to that protocol).
*/
extern(C) bool class_addProtocol(Class cls, Protocol* protocol) nothrow @nogc;

/**
Adds a property to a class.

Params:
	cls = (nullable) The class to modify.
	name = (non-null) The name of the property.
	attributes = (nullable) An array of property attributes.
	attributeCount = The number of attributes in `attributes`.

Returns: `true` if the property was added successfully, otherwise `false` (for example, the class already has that property).
*/
extern(C) bool class_addProperty(Class cls, const(char)* name, const(objc_property_attribute_t)* attributes, uint attributeCount) nothrow @nogc;

/**
Replace a property of a class.

Params:
	cls = (nullable) The class to modify.
	name = (non-null) The name of the property.
	attributes = (nullable) An array of property attributes.
	attributeCount = The number of attributes in `attributes`.
*/
extern(C) void class_replaceProperty(Class cls, const(char)* name, const(objc_property_attribute_t)* attributes, uint attributeCount) nothrow @nogc;

/**
Sets the Ivar layout for a given class.

Params:
	cls = (nullable) The class to modify.
	layout = (nullable) The layout of the `Ivars` for `cls`.
*/
extern(C) void class_setIvarLayout(Class cls, const(ubyte)* layout) nothrow @nogc;

/**
Sets the layout for weak Ivars for a given class.

Params:
	cls = (nullable) The class to modify.
	layout = (nullable) The layout of the weak Ivars for `cls`.
*/
extern(C) void class_setWeakIvarLayout(Class cls, const(ubyte)* layout) nothrow @nogc;


//Instantiating Classes

/**
Creates an instance of a class, allocating memory for the class in the default malloc memory zone.

Params:
	cls = (nullable) The class that you wish to allocate an instance of.
	extraBytes = An integer indicating the number of extra bytes to allocate.
		The additional bytes can be used to store additional instance variables beyond those defined in the class definition.

Returns: (nullable) An instance of the class `cls`.
*/
extern(C) id class_createInstance(Class cls, size_t extraBytes) nothrow @nogc;


//Adding Classes

/**
Creates a new class and metaclass.

Params:
	superclass = (nullable) The class to use as the new class's superclass, or `Nil` to create a new root class.
	name = (non-null) The string to use as the new class's name. The string will be copied.
	extraBytes = The number of bytes to allocate for indexed ivars at the end of the class and metaclass objects. This should usually be `0`.

Returns: (nullable) The new class, or Nil if the class could not be created (for example, the desired name is already in use).

Note: You can get a pointer to the new metaclass by calling `object_getClass`(newClass).
Note: To create a new class, start by calling `objc_allocateClassPair`. Then set the class's attributes with functions like `class_addMethod` and `class_addIvar`. When you are done building the class, call `objc_registerClassPair`. The new class is now ready for use.
Note: Instance methods and instance variables should be added to the class itself. Class methods should be added to the metaclass.
*/
extern(C) Class objc_allocateClassPair(Class superclass, const(char)* name, size_t extraBytes) nothrow @nogc;

/**
Registers a class that was allocated using `objc_allocateClassPair`.

Params:
	cls = (non-null) The class you want to register.
*/
extern(C) void objc_registerClassPair(Class cls) nothrow @nogc;

/**
Used by Foundation's Key-Value Observing.

Params:
	original = (non-null)
	name = (non-null)

Returns: (non-null)

Warning: Do not call this function yourself.
*/
extern(C) Class objc_duplicateClass(Class original, const(char)* name, size_t extraBytes) nothrow @nogc;
/**
Destroy a class and its associated metaclass.

Params:
	cls = (non-null) The class to be destroyed. It must have been allocated with `objc_allocateClassPair`

Warning: Do not call if instances of this class or a subclass exist.
*/
extern(C) void objc_disposeClassPair(Class cls) nothrow @nogc;


//Working with Methods

/**
Returns the name of a method.

Params:
	m = (non-null) The method to inspect.

Returns: (non-null) A pointer of type SEL.

Note: To get the method name as a C string, call `sel_getName`(method_getName(method)).
*/
extern(C) SEL method_getName(Method m) nothrow @nogc;

/**
Returns the implementation of a method.

Params:
	m = (non-null) The method to inspect.

Returns: (non-null) A function pointer of type IMP.
*/
extern(C) IMP method_getImplementation(Method m) nothrow @nogc;

/**
Returns a string describing a method's parameter and return types.

Params:
	m = (non-null) The method to inspect.

Returns: (nullable) A C string. The string may be `null`.
*/
extern(C) const(char)* method_getTypeEncoding(Method m) nothrow @nogc;

/**
Returns the number of arguments accepted by a method.

Params:
	m = (non-null) A pointer to a `Method` data structure. Pass the method in question.

Returns: An integer containing the number of arguments accepted by the given method.
*/
extern(C) uint method_getNumberOfArguments(Method m) nothrow @nogc;

/**
Returns a string describing a method's return type.

Params:
	m = (non-null) The method to inspect.

Returns: (non-null) A C string describing the return type. You must free the string with `free`.
*/
extern(C) char* method_copyReturnType(Method m) nothrow @nogc;

/**
Returns a string describing a single parameter type of a method.

Params:
	m = (non-null) The method to inspect.
	index = The index of the parameter to inspect.

Returns: (nullable) A C string describing the type of the parameter at index `index`, or `null` if method has no parameter index `index`. You must free the string with `free`.
*/
extern(C) char* method_copyArgumentType(Method m, uint index) nothrow @nogc;

/**
Returns by reference a string describing a method's return type.

Params:
	m = (non-null) The method you want to inquire about.
	dst = (non-null) The reference string to store the description.
	dst_len = The maximum number of characters that can be stored in `dst`.

Note: The method's return type string is copied to `dst`. `dst` is filled as if `strncpy`(dst, parameter_type, dst_len) were called.
*/
extern(C) void method_getReturnType(Method m, char* dst, size_t dst_len) nothrow @nogc;

/**
Returns by reference a string describing a single parameter type of a method.

Params:
	m = (non-null) The method you want to inquire about.
	index = The index of the parameter you want to inquire about.
	dst = (nullable) The reference string to store the description.
	dst_len = The maximum number of characters that can be stored in `dst`.

Note: The parameter type string is copied to `dst`. `dst` is filled as if `strncpy`(dst, parameter_type, dst_len) were called. If the method contains no parameter with that index, `dst` is filled as if `strncpy`(dst, "", dst_len) were called.
*/
extern(C) void method_getArgumentType(Method m, uint index, char* dst, size_t dst_len) nothrow @nogc;

/**
Params:
	m = (non-null)

Returns: (non-null)
*/
extern(C) objc_method_description* method_getDescription(Method m) nothrow @nogc;

/**
Sets the implementation of a method.

Params:
	m = (non-null) The method for which to set an implementation.
	imp = (non-null) The implementation to set to this method.

Returns: (non-null) The previous implementation of the method.
*/
extern(C) IMP method_setImplementation(Method m, IMP imp) nothrow @nogc;

/**
Exchanges the implementations of two methods.

Params:
	m1 = (non-null) Method to exchange with second method.
	m2 = (non-null) Method to exchange with first method.

Note: This is an atomic version of the following:
```d
IMP imp1 = method_getImplementation(m1);
IMP imp2 = method_getImplementation(m2);
method_setImplementation(m1, imp2);
method_setImplementation(m2, imp1);
```
*/
extern(C) void method_exchangeImplementations(Method m1, Method m2) nothrow @nogc;


//Working with Instance Variables

/**
Returns the name of an instance variable.

Params:
	v = (non-null) The instance variable you want to enquire about.

Returns: (nullable) A C string containing the instance variable's name.
*/
extern(C) const(char)* ivar_getName(Ivar v) nothrow @nogc;

/**
Returns the type string of an instance variable.

Params:
	v = (non-null) The instance variable you want to enquire about.

Returns: (nullable) A C string containing the instance variable's type encoding.

Note: For possible values, see Objective-C Runtime Programming Guide > Type Encodings.
*/
extern(C) const(char)* ivar_getTypeEncoding(Ivar v) nothrow @nogc;

/**
Returns the offset of an instance variable.

Params:
	v = (non-null) The instance variable you want to enquire about.

Returns: The offset of `v`.

Note: For instance variables of type `id` or other object types, call `object_getIvar` and `object_setIvar` instead of using this offset to access the instance variable data directly.
*/
extern(C) ptrdiff_t ivar_getOffset(Ivar v) nothrow @nogc;


//Working with Properties

/**
Returns the name of a property.

Params:
	property = (non-null) The property you want to inquire about.

Returns: (non-null) A C string containing the property's name.
*/
extern(C) const(char)* property_getName(objc_property_t property) nothrow @nogc;

/**
Returns the attribute string of a property.

Params:
	property = (non-null) A property.

Returns: (nullable) A C string containing the property's attributes.

Note: The format of the attribute string is described in Declared Properties in Objective-C Runtime Programming Guide.
*/
extern(C) const(char)* property_getAttributes(objc_property_t property) nothrow @nogc;

/**
Returns an array of property attributes for a property.

Params:
	property = (non-null) The property whose attributes you want copied.
	outCount = (nullable) The number of attributes returned in the array.

Returns: (nullable) An array of property attributes; must be free'd() by the caller.
*/
extern(C) objc_property_attribute_t* property_copyAttributeList(objc_property_t property, uint* outCount) nothrow @nogc;

/**
Returns the value of a property attribute given the attribute name.

Params:
	property = (non-null) The property whose attribute value you are interested in.
	attributeName = (non-null) C string representing the attribute name.

Returns: (nullable) The value string of the attribute `attributeName` if it exists in `property`, `nil` otherwise.
*/
extern(C) char* property_copyAttributeValue(objc_property_t property, const(char)* attributeName) nothrow @nogc;


//Working with Protocols

/**
Returns a specified protocol.

Params:
	name = (non-null) The name of a protocol.

Returns: (nullable) The protocol named `name`, or `null` if no protocol named `name` could be found.

Note: This function acquires the runtime lock.
*/
extern(C) Protocol* objc_getProtocol(const(char)* name) nothrow @nogc;

/**
Returns an array of all the protocols known to the runtime.

Params:
	outCount = (nullable) Upon return, contains the number of protocols in the returned array.

Returns: (nullable pointer to non-null `Protocol` pointer) A C array of all the protocols known to the runtime. The array contains `*outCount` pointers followed by a `null` terminator. You must free the list with `free`.

Note: This function acquires the runtime lock.
*/
extern(C) Protocol** objc_copyProtocolList(uint* outCount) nothrow @nogc;

/**
Returns a Boolean value that indicates whether one protocol conforms to another protocol.

Params:
	proto = (nullable) A protocol.
	other = (nullable) A protocol.

Returns: `true` if `proto` conforms to `other`, otherwise `false`.

Note: One protocol can incorporate other protocols using the same syntax that classes use to adopt a protocol:
```objc
@protocol ProtocolName <protocol list>
```
All the protocols listed between angle brackets are considered part of the `ProtocolName` protocol.
*/
extern(C) bool protocol_conformsToProtocol(Protocol* proto, Protocol* other) nothrow @nogc;

/**
Returns a Boolean value that indicates whether two protocols are equal.

Params:
	proto = (nullable) A protocol.
	other = (nullable) A protocol.

Returns: `true` if `proto` is the same as `other`, otherwise `false`.
*/
extern(C) bool protocol_isEqual(Protocol* proto, Protocol* other) nothrow @nogc;

/**
Returns the name of a protocol.

Params:
	proto = (non-null) A protocol.

Returns: (non-null) The name of the protocol `p` as a C string.
*/
extern(C) const(char)* protocol_getName(Protocol* proto) nothrow @nogc;

/**
Returns a method description structure for a specified method of a given protocol.

Params:
	proto = (non-null) A protocol.
	aSel = (non-null) A selector.
	isRequiredMethod = A Boolean value that indicates whether aSel is a required method.
	isInstanceMethod = A Boolean value that indicates whether aSel is an instance method.

Returns: An `objc_method_description` structure that describes the method specified by `aSel`, `isRequiredMethod`, and `isInstanceMethod` for the protocol `p`. If the protocol does not contain the specified method, returns an `objc_method_description` structure with the value `[null, null]`.

Note: This function recursively searches any protocols that this protocol conforms to.
*/
extern(C) objc_method_description protocol_getMethodDescription(Protocol* proto, SEL aSel, bool isRequiredMethod, bool isInstanceMethod) nothrow @nogc;

/**
Returns an array of method descriptions of methods meeting a given specification for a given protocol.

Params:
	proto = (non-null) A protocol.
	isRequiredMethod = A Boolean value that indicates whether returned methods should be required methods (pass `true` to specify required methods).
	isInstanceMethod = A Boolean value that indicates whether returned methods should be instance methods (pass `true` to specify instance methods).
	outCount = (nullable) Upon return, contains the number of method description structures in the returned array.

Returns: (nullable) A C array of `objc_method_description` structures containing the names and types of `p`'s methods specified by `isRequiredMethod` and `isInstanceMethod`. The array contains `*outCount` pointers followed by a `null` terminator. You must free the list with `free`. If the protocol declares no methods that meet the specification, `null` is returned and `*outCount` is 0.

Note: Methods in other protocols adopted by this protocol are not included.
*/
extern(C) objc_method_description* protocol_copyMethodDescriptionList(Protocol* proto, bool isRequiredMethod, bool isInstanceMethod, uint* outCount) nothrow @nogc;

/**
Returns the specified property of a given protocol.

Params:
	proto = (non-null) A protocol.
	name = (non-null) The name of a property.
	isRequiredProperty = `true` searches for a required property, `false` searches for an optional property.
	isInstanceProperty = `true` searches for an instance property, `false` searches for a class property.

Returns: (nullable) The property specified by `name`, `isRequiredProperty`, and `isInstanceProperty` for `proto`, or `null` if none of `proto`'s properties meets the specification.
*/
extern(C) objc_property_t protocol_getProperty(Protocol* proto, const(char)* name, bool isRequiredProperty, bool isInstanceProperty) nothrow @nogc;

/**
Returns an array of the required instance properties declared by a protocol.

Params:
	proto = (non-null)
	outcount = (nullable)

Returns: (nullable pointer to non-null `objc_property_t`)

Note: Identical to
```d
protocol_copyPropertyList2(proto, outCount, true, true);
```
*/
extern(C) objc_property_t* protocol_copyPropertyList(Protocol* proto, uint* outCount) nothrow @nogc;

/**
Returns an array of properties declared by a protocol.

Params:
	proto = (non-null) A protocol.
	outCount = (nullable) Upon return, contains the number of elements in the returned array.
	isRequiredProperty = `true` returns required properties, `false` returns optional properties.
	isInstanceProperty = `true` returns instance properties, `false` returns class properties.

Returns: (nullable pointer to non-null `objc_property_t`) A C array of pointers of type `objc_property_t` describing the properties declared by `proto`. Any properties declared by other protocols adopted by this protocol are not included. The array contains `*outCount` pointers followed by a `null` terminator. You must free the array with `free`. If the protocol declares no matching properties, `null` is returned and `*outCount` is `0`.
*/
extern(C) objc_property_t* protocol_copyPropertyList2(Protocol* proto, uint* outCount, bool isRequiredProperty, bool isInstanceProperty) nothrow @nogc;

/**
Returns an array of the protocols adopted by a protocol.

Params:
	proto = (non-null) A protocol.
	outCount = (nullable) Upon return, contains the number of elements in the returned array.

Returns: (nullable pointer to non-null `Protocol` pointer) A C array of protocols adopted by `proto`. The array contains `*outCount` pointers followed by a `null` terminator. You must free the array with `free`. If the protocol adopts no other protocols, `null` is returned and `*outCount` is `0`.
*/
extern(C) Protocol** protocol_copyProtocolList(Protocol* proto, uint* outCount) nothrow @nogc;

/**
Creates a new protocol instance that cannot be used until registered with `objc_registerProtocol`

Params:
	name = (non-null) The name of the protocol to create.

Returns: (nullable) The Protocol instance on success, `nil` if a protocol with the same name already exists.

Note: There is no dispose method for this.
*/
extern(C) Protocol* objc_allocateProtocol(const(char)* name) nothrow @nogc;

/**
Registers a newly constructed protocol with the runtime. The protocol
will be ready for use and is immutable after this.

Params:
	proto = (non-null) The protocol you want to register.
*/
extern(C) void objc_registerProtocol(Protocol* proto) nothrow @nogc;

/**
Adds a method to a protocol. The protocol must be under construction.

Params:
	proto = (non-null) The protocol to add a method to.
	name = (non-null) The name of the method to add.
	types = (nullable) A C string that represents the method signature.
	isRequiredMethod = `true` if the method is not an optional method.
	isInstanceMethod = `true` if the method is an instance method.
*/
extern(C) void protocol_addMethodDescription(Protocol* proto, SEL name, const(char)* types, bool isRequiredMethod, bool isInstanceMethod) nothrow @nogc;

/**
Adds an incorporated protocol to another protocol. The protocol being
added to must still be under construction, while the additional protocol
must be already constructed.

Params:
	proto = (non-null) The protocol you want to add to, it must be under construction.
	addition = (non-null) The protocol you want to incorporate into `proto`, it must be registered.
*/
extern(C) void protocol_addProtocol(Protocol* proto, Protocol* addition) nothrow @nogc;

/**
Adds a property to a protocol. The protocol must be under construction.

Params:
	proto = (non-null) The protocol to add a property to.
	name = (non-null) The name of the property.
	attributes = (nullable) An array of property attributes.
	attributeCount = The number of attributes in `attributes`.
	isRequiredProperty = `true` if the property (accessor methods) is not optional.
	isInstanceProperty = `true` if the property (accessor methods) are instance methods. This is the only case allowed fo a property, as a result, setting this to `false` will not add the property to the protocol at all.
*/
extern(C) void protocol_addProperty(Protocol* proto, const(char)* name, const(objc_property_attribute_t)* attributes, uint attributeCount, bool isRequiredProperty, bool isInstanceProperty) nothrow @nogc;


//Working with Libraries

/**
Returns the names of all the loaded Objective-C frameworks and dynamic
libraries.

Params:
	outCount = (nullable) The number of names returned.

Returns: (non-null) An array of C strings of names. Must be free()'d by caller.
*/
extern(C) const(char)** objc_copyImageNames(uint* outCount) nothrow @nogc;

/**
Returns the dynamic library name a class originated from.

Params:
	cls = (nullable) The class you are inquiring about.

Returns: (nullable) The name of the library containing this class.
*/
extern(C) const(char)* class_getImageName(Class cls) nothrow @nogc;

/**
Returns the names of all the classes within a library.

Params:
	image = (non-null) The library or framework you are inquiring about.
	outCount = (nullable) The number of class names returned.

Returns: (nullable pointer to non-null `const(char)` pointer) An array of C strings representing the class names.
*/
extern(C) const(char)** objc_copyClassNamesForImage(const(char)* image, uint* outCount) nothrow @nogc;


//Working with Selectors

/**
Returns the name of the method specified by a given selector.

Params:
	sel = (non-null) A pointer of type `SEL`. Pass the selector whose name you wish to determine.

Returns: (non-null) A C string indicating the name of the selector.
*/
extern(C) const(char)* sel_getName(SEL sel) nothrow @nogc;

/**
Registers a method with the Objective-C runtime system, maps the method name to a selector, and returns the selector value.

Params:
	str = (non-null) A pointer to a C string. Pass the name of the method you wish to register.

Returns: (non-null) A pointer of type `SEL` specifying the selector for the named method.

Note: You must register a method name with the Objective-C runtime system to obtain the method’s selector before you can add the method to a class definition.
If the method name has already been registered, this function simply returns the selector.
*/
extern(C) SEL sel_registerName(const(char)* str) nothrow @nogc;

/**
Returns a Boolean value that indicates whether two selectors are equal.

Params:
	lhs = (non-null) The selector to compare with rhs.
	rhs = (non-null) The selector to compare with lhs.

Returns: `true` if `lhs` and `rhs` are equal, otherwise `false`.

Note: sel_isEqual is equivalent to ==.
*/
extern(C) bool sel_isEqual(SEL lhs, SEL rhs) nothrow @nogc;


//Objective-C Language Features

/**
This function is inserted by the compiler when a mutation is detected during a foreach iteration.
It gets called when a mutation occurs, and the `enumerationMutationHandler` is enacted if it is set up. A fatal error occurs if a handler is not set up.

Params:
	obj = (non-null) The object being mutated.

*/
extern(C) void objc_enumerationMutation(id obj) nothrow @nogc;

/**
Sets the current mutation handler.

Params:
	handler = (nullable) Function pointer to the new mutation handler.
*/
extern(C) void objc_setEnumerationMutationHandler(void function(id /*(non-null)*/) handler) nothrow @nogc;

/**
Set the function to be called by objc_msgForward.

Params:
	fwd = (non-null) Function to be jumped to by objc_msgForward.
	fwd_stret = (non-null) Function to be jumped to by objc_msgForward_stret.

See: `objc.message._objc_msgForward`
*/
extern(C) void objc_setForwardHandler(void* fwd, void* fwd_stret) nothrow @nogc;

/**
Creates a pointer to a function that will call the block
when the method is called.

Params:
	block = (non-null) The block that implements this method. Its signature should be: `method_return_type ^(id self, method_args...)`. The selector is not available as a parameter to this block. The block is copied with `Block_copy`.

Returns: (non-null) The IMP that calls this block. Must be disposed of with `imp_removeBlock`.
*/
extern(C) IMP imp_implementationWithBlock(id block) nothrow @nogc;

/**
Return the block associated with an IMP that was created using
`imp_implementationWithBlock`.

Params:
	anImp = (non-null) The IMP that calls this block.

Returns: (nullable) The block called by `anImp`.
*/
extern(C) id imp_getBlock(IMP anImp) nothrow @nogc;

/**
Disassociates a block from an IMP that was created using `imp_implementationWithBlock` and releases the copy of the block that was created.

Params:
	anImp = (non-null) An IMP that was created using `imp_implementationWithBlock`.

Returns: `true` if the block was released successfully, `false` otherwise. (For example, the block might not have been used to create an `IMP` previously).
*/
extern(C) bool imp_removeBlock(IMP anImp) nothrow @nogc;

/**
This loads the object referenced by a weak pointer and returns it, after
retaining and autoreleasing the object to ensure that it stays alive
long enough for the caller to use it. This function would be used
anywhere a __weak variable is used in an expression.

Params:
	location = (non-null pointer to nullable `id`) The weak pointer address

Returns: (nullable) The object pointed to by `location`, or `nil` if `*location` is `nil`.
*/
extern(C) id objc_loadWeak(id* location) nothrow @nogc;

/**
This function stores a new value into a __weak variable. It would
be used anywhere a __weak variable is the target of an assignment.

Params:
	location = (non-null pointer to nullable `id`) The address of the weak pointer itself
	obj = (nullable) The new object this weak ptr should now point to

Returns: (nullable) The value stored into `location`, i.e. `obj`
*/
extern(C) id objc_storeWeak(id* location, id obj) nothrow @nogc;


//Associative References

///Convert base 10 input to base 8
uint oct(uint n){
	uint ret=0, shift=0;
	while(n > 0){
		ret += (n % 10) << shift;
		n /= 10;
		shift += 3;
	}
	return ret;
}

/**
Policies related to associative references.
These are options to `objc_setAssociatedObject`
*/
alias objc_AssociationPolicy = size_t;
enum: objc_AssociationPolicy{
	OBJC_ASSOCIATION_ASSIGN            = 0, ///Specifies a weak reference to the associated object.
	OBJC_ASSOCIATION_RETAIN_NONATOMIC  = 1, ///Specifies a strong reference to the associated object. The association is not made atomically.
	OBJC_ASSOCIATION_COPY_NONATOMIC    = 3, ///Specifies that the associated object is copied. The association is not made atomically.
	OBJC_ASSOCIATION_RETAIN            = oct(1401), ///Specifies a strong reference to the associated object. The association is made atomically.
	OBJC_ASSOCIATION_COPY              = oct(1403), ///Specifies that the associated object is copied. The association is made atomically.
}

/**
Sets an associated value for a given object using a given key and association policy.

Params:
	object = (non-null) The source object for the association.
	key = (non-null) The key for the association.
	value = (nullable) The value to associate with the key key for object. Pass nil to clear an existing association.
	policy = The policy for the association. For possible values, see “Associative Object Behaviors.”

See: `objc_setAssociatedObject`

See: `objc_removeAssociatedObjects`
*/
extern(C) void objc_setAssociatedObject(id object, const(void)* key, id value, objc_AssociationPolicy policy) nothrow @nogc;

/**
Returns the value associated with a given object for a given key.

Params:
	object = (non-null) The source object for the association.
	key = (non-null) The key for the association.

Returns: (nullable) The value associated with the key `key` for `object`.

See: `objc_setAssociatedObject`
*/
extern(C) id objc_getAssociatedObject(id object, const(void)* key) nothrow @nogc;

/**
Removes all associations for a given object.

Params:
	object = (non-null) An object that maintains associated objects.

Note: The main purpose of this function is to make it easy to return an object to a "pristine state”.
You should not use this function for general removal of associations from objects, since it also removes associations that other clients may have added to the object.
Typically you should use `objc_setAssociatedObject` with a nil value to clear an association.

See: `objc_setAssociatedObject`

See: `objc_getAssociatedObject`
*/
extern(C) void objc_removeAssociatedObjects(id object) nothrow @nogc;


//Hooks for Swift

/**
Function type for a hook that intercepts class_getImageName().

Params:
	cls = (non-null) The class whose image name is being looked up.
	outImageName = (non-null pointer to nullable `const(char)` pointer) On return, the result of the image name lookup.

Returns: `true` if an image name for this class was found, `false` otherwise.

See: `class_getImageName`

See: `objc_setHook_getImageName`
*/
alias objc_hook_getImageName = bool function(Class cls, const(char)** outImageName);

/**
Install a hook for `class_getImageName`.

Params:
	newValue = The hook function to install.
	outOldValue = (non-null pointer to nullable `objc_hook_getImageName`) The address of a function pointer variable.
		On return, the old hook function is stored in the variable.

Note: The store to `*outOldValue` is thread-safe: the variable will be updated before `class_getImageName` calls your new hook to read it,
even if your new hook is called from another thread before this setter completes.

Note: The first hook in the chain is the native implementation of `class_getImageName`. Your hook should call the previous hook for classes that you do not recognise.

See: `class_getImageName`

See: `objc_hook_getImageName`
*/
extern(C) void objc_setHook_getImageName(objc_hook_getImageName newValue, objc_hook_getImageName* outOldValue) nothrow @nogc;

/**
Function type for a hook that assists objc_getClass() and related functions.

Params:
	name = (non-null) The class name to look up.
	outClass = (non-null pointer to nullable `Class`) On return, the result of the class lookup.

Returns: `true` if a class with this name was found, `false` otherwise.

See: `objc_getClass`

See: `objc_setHook_getClass`
*/
alias objc_hook_getClass = bool function(const(char)* name, Class* outClass);

version(OSX){
	version(X86){
		version = OSX_X86;
	}
}

version(OSX_X86){
}else{
	/**
	Install a hook for objc_getClass() and related functions.
	
	Params:
		newValue = (non-null) The hook function to install.
		outOldValue = (non-null pointer to nullable `objc_hook_getClass`) The address of a function pointer variable.
			On return, the old hook function is stored in the variable.
	
	Note: The store to `*outOldValue` is thread-safe: the variable will be updated before `objc_getClass` calls your new hook to read it,
	even if your new hook is called from another thread before this setter completes.
	
	Note: Your hook should call the previous hook for class names that you do not recognise.
	
	See: `objc_getClass`
	
	See: `objc_hook_getClass`
	*/
	extern(C) void objc_setHook_getClass(objc_hook_getClass newValue, objc_hook_getClass* outOldValue);
}

struct mach_header;

/**
Function type for a function that is called when an image is loaded.

Params:
	header = (non-null) The newly loaded header.
*/
alias objc_func_loadImage = void function(const(mach_header)* header);

/**
Add a function to be called when a new image is loaded.
The function is called after ObjC has scanned and fixed up the image. It is called BEFORE +load methods are invoked.

When adding a new function, that function is immediately called with all images that are currently loaded.
It is then called as needed for images that are loaded afterwards.

Note: the function is called with ObjC's internal runtime lock held.
Be VERY careful with what the function does to avoid deadlocks or poor performance.

Params:
	func = (non-null) The function to add.
*/
extern(C) void objc_addLoadImageFunc(objc_func_loadImage func) nothrow @nogc;

/**
Function type for a hook that provides a name for lazily named classes.

Params:
	cls = (non-null) The class to generate a name for.

Returns: (nullable) The name of the class, or `null` if the name isn't known or can't me generated.

See: `objc_setHook_lazyClassNamer`
*/
alias objc_hook_lazyClassNamer = const(char)* function(Class cls);

/**
Install a hook to provide a name for lazily-named classes.

Params:
	newValue = (non-null) The hook function to install.
	outOldValue = (non-null) The address of a function pointer variable. On return, the old hook function is stored in the variable.

Note: The store to `*outOldValue` is thread-safe: the variable will be updated before `objc_getClass` calls your new hook to read it, even if your new hook is called from another thread before this setter completes.

Note: Your hook must call the previous hook for class names that you do not recognise.
*/
version(OSX_X86){
}else{
	extern(C) void objc_setHook_lazyClassNamer(objc_hook_lazyClassNamer newValue, objc_hook_lazyClassNamer* oldOutValue) nothrow @nogc;
	
	/**
	Callback from Objective-C to Swift to perform Swift class initialisation.
	
	Params:
		cls = (non-null)
		arg = (nullable)
	
	Returns: (nullable)
	*/
	alias _objc_swiftMetadataInitializer = Class function(Class cls, void* arg);
	alias _objc_swiftMetadataInitialiser = _objc_swiftMetadataInitializer;
	
	/**
	Perform Objective-C initialisation of a Swift class.
	Do not call this function. It is provided for the Swift runtime's use only and will change without notice or mercy.
	
	Params:
		cls = (nullable)
		previously = (nullable)
	
	Returns: (nullable)
	*/
	extern(C) Class _objc_realizeClassFromSwift(Class cls, void* previously);
	alias _objc_realiseClassFromSwift = _objc_realizeClassFromSwift;
}

///Type encoding characters
enum{
	_C_ID          = '@',
	_C_CLASS       = '#',
	_C_SEL         = ':',
	_C_CHR         = 'c',
	_C_UCHR        = 'C',
	_C_SHT         = 's',
	_C_USHT        = 'S',
	_C_INT         = 'i',
	_C_UINT        = 'I',
	_C_LNG         = 'l',
	_C_ULNG        = 'L',
	_C_LNG_LNG     = 'q',
	_C_ULNG_LNG    = 'Q',
	_C_INT128      = 't',
	_C_UINT128     = 'T',
	_C_FLT         = 'f',
	_C_DBL         = 'd',
	_C_LNG_DBL     = 'D',
	_C_BFLD        = 'b',
	_C_bool        = 'B',
	_C_VOID        = 'v',
	_C_UNDEF       = '?',
	_C_PTR         = '^',
	_C_CHARPTR     = '*',
	_C_ATOM        = '%',
	_C_ARY_B       = '[',
	_C_ARY_E       = ']',
	_C_UNION_B     = '(',
	_C_UNION_E     = ')',
	_C_STRUCT_B    = '{',
	_C_STRUCT_E    = '}',
	_C_VECTOR      = '!',
}

///Modifiers
enum{
	_C_COMPLEX      = 'j',
	_C_ATOMIC       = 'A',
	_C_CONST        = 'r',
	_C_IN           = 'n',
	_C_INOUT        = 'N',
	_C_OUT          = 'o',
	_C_BYCOPY       = 'O',
	_C_BYREF        = 'R',
	_C_ONEWAY       = 'V',
	_C_GNUREGISTER  = '+',
}

struct objc_method_list;

SEL getSEL(const(char)* selector)() nothrow @nogc{
	static SEL sel = null;
	if(sel is null){
		sel = sel_registerName(selector);
	}
	return sel;
}

Class getClass(const(char)* name)() nothrow @nogc{
	static Class class_ = null;
	if(class_ is null){
		class_ = objc_getClass(name);
	}
	return class_;
}

Protocol* getProtocol(const(char)* name)() nothrow @nogc{
	static Protocol* protocol = null;
	if(protocol is null){
		protocol = objc_getProtocol(name);
	}
	return protocol;
}
