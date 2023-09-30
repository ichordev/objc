module objc.nsobject;

import objc;

struct NSString;
struct NSMethodSignature;
struct NSInvocation;

mixin template Proto_NSObject(){
	
	mixin (makeMemberFn(q{bool}, q{isEqual},`:`, q{id object}));
	@property mixin(makeStaticMemberFn(q{NSUInteger}, q{hash},``, q{}));
	
	@property mixin(makeStaticMemberFn(q{Class}, q{superclass},``, q{}));
	
	mixin(makeMemberFn(q{bool}, q{isProxy},``, q{}));
	
	mixin(makeStaticMemberFn(q{bool}, q{isKindOfClass},`:`, q{Class aClass}));
	mixin(makeStaticMemberFn(q{bool}, q{isMemberOfClass},`:`, q{Class aClass}));
	mixin(makeStaticMemberFn(q{bool}, q{conformsToProtocol},`:`, q{Protocol* protocol}));

	mixin(makeStaticMemberFn(q{bool}, q{respondsToSelector},`:`, q{SEL aSelector}));
	
	@property mixin(makeStaticMemberFn(q{NSString*}, q{description},``, q{}));
	//@optional @property (readonly, copy) NSString *debugDescription;
}

mixin template Inter_NSObject(){
	mixin Proto_NSObject!();
	
	deprecated Class isa;
	
	mixin(makeStaticMemberFn(q{void}, q{load},``, q{}));
	
	mixin(makeStaticMemberFn(q{void}, q{initialize},``, q{}));
	alias initialise = initialize;
	mixin(makeMemberFn(q{typeof(this)}, q{init},``, q{}));
	
	//mixin(makeStaticMemberFn(q{typeof(this)}, q{new_}, `new`, q{})) OBJC_SWIFT_UNAVAILABLE("use object initializers instead");
	//mixin(makeStaticMemberFn(q{typeof(this)}, q{allocWithZone},`:`, q{_NSZone* zone})) OBJC_SWIFT_UNAVAILABLE("use object initializers instead");
	//mixin(makeStaticMemberFn(q{typeof(this)}, q{alloc},``, q{})) OBJC_SWIFT_UNAVAILABLE("use object initializers instead");
	//- (void)dealloc OBJC_SWIFT_UNAVAILABLE("use 'deinit' to define a de-initializer");
	
	mixin(makeMemberFn(q{id}, q{copy},``, q{}));
	mixin(makeMemberFn(q{id}, q{mutableCopy},``, q{}));
	
	
	mixin(makeStaticMemberFn(q{bool}, q{instancesRespondToSelector},`:`, q{SEL aSelector}));
	mixin(makeMemberFn(q{void}, q{doesNotRecognizeSelector},`:`, q{SEL aSelector}));
	alias doesNotRecogniseSelector = doesNotRecognizeSelector;
	
	//- (void)forwardInvocation:(NSInvocation *)anInvocation OBJC_SWIFT_UNAVAILABLE("");
	
	mixin(makeStaticMemberFn(q{bool}, q{isSubclassOfClass},`:`, q{Class aClass}));
	
	mixin(makeStaticMemberFn(q{bool}, q{resolveClassMethod},`:`, q{SEL sel}));
	mixin(makeStaticMemberFn(q{bool}, q{resolveInstanceMethod},`:`, q{SEL sel}));
	
}
