module objc.nsobject;

import objc;

struct _NSZone;

struct NSString;
struct NSMethodSignature;
struct NSInvocation;

mixin template Proto_NSObject(){
	alias instancetype = typeof(this)*;
	@disable this(ref typeof(this));
	
	mixin(makeMethod(q{bool}, q{isEqual},`:`, q{id object}));
	mixin(makeMethod(q{NSUInteger}, q{hash},``, q{}));
	
	mixin(makeStaticMethod(q{Class}, q{superclass},``, q{}));
	
	mixin(makeMethod(q{bool}, q{isProxy},``, q{}));
	
	mixin(makeStaticMethod(q{bool}, q{isKindOfClass},`:`, q{Class aClass}));
	mixin(makeStaticMethod(q{bool}, q{isMemberOfClass},`:`, q{Class aClass}));
	mixin(makeStaticMethod(q{bool}, q{conformsToProtocol},`:`, q{Protocol* protocol}));

	mixin(makeStaticMethod(q{bool}, q{respondsToSelector},`:`, q{SEL aSelector}));
	
	@property mixin(makeStaticMethod(q{NSString*}, q{description},``, q{}));
	//@optional @property (readonly, copy) NSString *debugDescription;
}

mixin(makeClass(q{NSObject},[], [q{Proto_NSObject!()}], q{
	deprecated Class isa;
	
	mixin(makeStaticMethod(q{void}, q{load},``, q{}));
	
	mixin(makeStaticMethod(q{void}, q{initialize},``, q{}));
	alias initialise = initialize;
	mixin(makeMethod(q{instancetype}, q{init},``, q{}));
	
	mixin(makeStaticMethod(q{instancetype}, q{new_}, `new`, q{}));
	mixin(makeStaticMethod(q{instancetype}, q{allocWithZone},`:`, q{_NSZone* zone}));
	mixin(makeStaticMethod(q{instancetype}, q{alloc},``, q{}));
	mixin(makeMethod(q{void}, q{dealloc},``, q{}));
	
	mixin(makeMethod(q{id}, q{copy},``, q{}));
	mixin(makeMethod(q{id}, q{mutableCopy},``, q{}));
	
	
	mixin(makeStaticMethod(q{bool}, q{instancesRespondToSelector},`:`, q{SEL aSelector}));
	mixin(makeMethod(q{void}, q{doesNotRecognizeSelector},`:`, q{SEL aSelector}));
	alias doesNotRecogniseSelector = doesNotRecognizeSelector;
	
	//- (void)forwardInvocation:(NSInvocation *)anInvocation;
	
	mixin(makeStaticMethod(q{bool}, q{isSubclassOfClass},`:`, q{Class aClass}));
	
	mixin(makeStaticMethod(q{bool}, q{resolveClassMethod},`:`, q{SEL sel}));
	mixin(makeStaticMethod(q{bool}, q{resolveInstanceMethod},`:`, q{SEL sel}));
}));
