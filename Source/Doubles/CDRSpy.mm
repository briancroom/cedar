#import "NSInvocation+Cedar.h"
#import "CDRSpy.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "StubbedMethod.h"
#import "CedarDoubleImpl.h"
#import "CDRSpyInfo.h"

@interface NSInvocation (SpyForwarded)
@property (nonatomic, setter=cdr_setInvocationRecorded:) BOOL cdr_invocationRecorded;
- (BOOL)cdr_handledBySpyForwardInvocation;
@end
@implementation NSInvocation (SpyForwarded)

static const char *CDRSpyInvocationRecordedKey;
- (BOOL)cdr_invocationRecorded {
    return [objc_getAssociatedObject(self, &CDRSpyInvocationRecordedKey) boolValue];
}
- (void)cdr_setInvocationRecorded:(BOOL)recorded {
    objc_setAssociatedObject(self, &CDRSpyInvocationRecordedKey, @(recorded), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static const char *CDRSpyForwardInvocationKey;
- (BOOL)cdr_handledBySpyForwardInvocation {
    BOOL handled = [objc_getAssociatedObject(self, &CDRSpyForwardInvocationKey) boolValue];
    objc_setAssociatedObject(self, &CDRSpyForwardInvocationKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return handled;
}

@end


typedef void (*forwardInvocation_t)(id, SEL, id);

@interface NSObject (OriginalForwardInvocation)
- (void)cdr_originalForwardInvocation:(NSInvocation *)invocation;
@end
@implementation NSObject (OriginalForwardInvocation)

- (void)cdr_originalForwardInvocation:(NSInvocation *)invocation {
    //NSLog(@"In -[NSObject cdr_originalForwardInvocation:] (%@)", invocation);
    struct objc_super super = { self, [self superclass] };
    forwardInvocation_t superForwardInvocation = (forwardInvocation_t)objc_msg_lookup_super(&super, @selector(forwardInvocation:));
    superForwardInvocation(self, @selector(forwardInvocation:), invocation);
}

@end

@implementation CDRSpy

// Implement a "second chance" for message handling by adding a special forwardInvocation: implementation to any
// class that gets spied on, so that if spying stops while message forwarding is in progress, we don't crash
// because of hitting NSObject's forwardInvocation: implementation with a message that the real object actually
// responds to

static void CDRSpy_forwardInvocation(id self, SEL _cmd, NSInvocation *invocation) {
    printf("In special spy forwardInvocation with %s\n", [[invocation description] cString]);
    CDRSpyInfo *info = [CDRSpyInfo spyInfoForObject:self];
    if (info) {
        // We are still a spy
        if (invocation.cdr_invocationRecorded) {
            // If the invocation was recorded and we still ended up here, then we should call to the actual forwardInvocation:
            // Call it via objc_msgSendSuper in case our class has already switched back to CDRSpy, which doesn't implement cdr_originalForwardInvocation:
            printf("Calling original forward invocation: %s\n", [[invocation description] cString]);
            struct objc_super super = { self, info.spiedClass };
            forwardInvocation_t originalForwardInvocation = (forwardInvocation_t)objc_msg_lookup_super(&super, @selector(cdr_originalForwardInvocation:));
            originalForwardInvocation(self, @selector(cdr_originalForwardInvocation:), invocation);
        } else {
            // The invocation wasn't recorded even though we are a spy, so try it again
            printf("Re-invoking because we should still be a spy: %s\n", [[invocation description] cString]);
            //NSLog(@"Re-invoking as spy %@", invocation);
            [invocation invoke];
        }
    } else {
        // We aren't a spy anymore
        if ([invocation cdr_handledBySpyForwardInvocation]) {
            // If we've reached here a second time, then we are actually we supposed to hit forwardInvocation:.
            //NSLog(@"Calling the original forwardInvocation: for %@", invocation);
            [self cdr_originalForwardInvocation:invocation];
        } else {
            // Try it again! We may actually handle this message but we were still a spy when the message ws sent
            //NSLog(@"Re-invoking as non-spy %@", invocation);
            [invocation invoke];
        }
    }
}

static void CDRSpy_swizzle_forwardInvocation_for_class(Class clazz) {
    // After this operation, any existing -forwardInvocation: implementation from `clazz` will be moved
    // to -cdr_originalForwardInvocation:. If the class doesn't implement -forwardInvocation:, a no-op
    // implementation of -cdr_originalForwardInvocation: is provided on NSObject
    if (class_getMethodImplementation(clazz, @selector(forwardInvocation:)) != (IMP)CDRSpy_forwardInvocation && clazz != [NSObject class]) {
        IMP previousImplementation = class_replaceMethod(clazz, @selector(forwardInvocation:), (IMP)CDRSpy_forwardInvocation, "v@:@");
        if (previousImplementation) {
            class_addMethod(clazz, @selector(cdr_originalForwardInvocation:), previousImplementation, "v@:@");
        }
    }
}

+ (void)interceptMessagesForInstance:(id)instance {
    if (!instance) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot spy on nil" userInfo:nil];
    }

    Class instanceClass = object_getClass(instance);
    if (![instanceClass conformsToProtocol:@protocol(CedarDouble)]) {
        [CDRSpyInfo storeSpyInfoForObject:instance];
        NSLog(@"Turning %p into a spy", instance);
        CDRSpy_swizzle_forwardInvocation_for_class(instanceClass);
        object_setClass(instance, self);
    }
}

+ (void)stopInterceptingMessagesForInstance:(id)instance {
    if (!instance) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot stop spying on nil" userInfo:nil];
    }
    Class originalClass = [CDRSpyInfo spyInfoForObject:instance].spiedClass;
    if ([CDRSpyInfo clearSpyInfoForObject:instance]) {
        NSLog(@"Un-spyifying %p", instance);
        object_setClass(instance, originalClass);
    }
}

#pragma mark - Emulating the original object

- (id)retain {
    __block id that = self;
    //NSLog(@"Spy (%p, %s) %s", self, class_getName(object_getClass(self)), sel_getName(_cmd));
    CDRSpy_as_spied_class(self, ^{
        [that retain];
    });
    return self;
}

- (BOOL)retainWeakReference {
    //NSLog(@"Spy (%p, %s) %s", self, class_getName(object_getClass(self)), sel_getName(_cmd));
    __block id that = self;
    __block BOOL res = NO;
    CDRSpy_unsafe_as_spied_class(self, ^{
        res = [that retainWeakReference];
    });
    return res;
}

- (oneway void)release {
    //NSLog(@"Spy (%p, %s) %s", self, class_getName(object_getClass(self)), sel_getName(_cmd));
    __block id that = self;
    CDRSpy_as_spied_class(self, ^{
        [that release];
    });
}

- (id)autorelease {
    //NSLog(@"Spy (%p, %s) %s", self, class_getName(object_getClass(self)), sel_getName(_cmd));
    __block id that = self;
    CDRSpy_as_spied_class(self, ^{
        [that autorelease];
    });
    return self;
}

- (NSUInteger)retainCount {
    //NSLog(@"Spy (%p, %s) %s", self, class_getName(object_getClass(self)), sel_getName(_cmd));
    __block id that = self;
    __block NSUInteger count = 0;
    CDRSpy_as_spied_class(self, ^{
        count = [that retainCount];
    });
    return count;
}

- (NSString *)description {
    //NSLog(@"Spy (%p, %s) %s", self, class_getName(object_getClass(self)), sel_getName(_cmd));
    __block id that = self;
    __block NSString *description = nil;
    CDRSpy_as_spied_class(self, ^{
        description = [that description];
    });

    return description;
}

- (BOOL)isEqual:(id)object {
    //NSLog(@"Spy (%p, %s) %s", self, class_getName(object_getClass(self)), sel_getName(_cmd));
    __block id that = self;
    __block BOOL isEqual = NO;
    CDRSpy_as_spied_class(self, ^{
        isEqual = [that isEqual:object];
    });

    return isEqual;
}

- (NSUInteger)hash {
    //NSLog(@"Spy (%p, %s) %s", self, class_getName(object_getClass(self)), sel_getName(_cmd));
    __block id that = self;
    __block NSUInteger hash = 0;
    CDRSpy_as_spied_class(self, ^{
        hash = [that hash];
    });

    return hash;
}

- (Class)class {
    return [CDRSpyInfo publicClassForObject:self];
}

- (BOOL)isKindOfClass:(Class)aClass {
    Class originalClass = [CDRSpyInfo publicClassForObject:self];
    return [originalClass isSubclassOfClass:aClass];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    // NOTE: In concurrent situations, `self` may lose its spy status at any point
    //       during the execution of this method.
    //NSLog(@"Spy (%p, %s) forwardInvocation %@", self, class_getName(object_getClass(self)), invocation);

#ifdef __GNUSTEP_RUNTIME__ // GNUstep can look up a valid method signature even if -methodSignatureForSelector: returns nil
    if (![self methodSignatureForSelector:invocation.selector]) {
        //NSLog(@"Calling doesNotRecognizeSelector: from spy (%p, %s)", self, class_getName(object_getClass(self)));
        [self doesNotRecognizeSelector:invocation.selector];
    }
#endif

    CedarDoubleImpl *cedar_double_impl = CDRSpy_cedar_double_impl(self);
    [cedar_double_impl record_method_invocation:invocation];
    int method_invocation_result = [cedar_double_impl invoke_stubbed_method:invocation];

    invocation.cdr_invocationRecorded = YES;
    [invocation cdr_copyBlockArguments];
    [invocation retainArguments];

    if (method_invocation_result != CDRStubMethodInvoked) {
        __block id forwardingTarget = nil;
        __block id that = self;

        SEL selector = invocation.selector;
        CDRSpy_as_spied_class(self, ^{
            forwardingTarget = [that forwardingTargetForSelector:selector];
        });

        if (forwardingTarget) {
            [invocation invokeWithTarget:forwardingTarget];
        } else {
            CDRSpyInfo *spyInfo = [CDRSpyInfo spyInfoForObject:self];
            IMP privateImp = [spyInfo impForSelector:selector];
            if (privateImp) {
                //NSLog(@"  Invoking using IMP");
                [invocation invokeUsingIMP:privateImp];
            } else {
                __block id that = self;
                CDRSpy_as_spied_class(self, ^{
                    //NSLog(@"  Calling invoke");
                    [invocation invoke];
                    [spyInfo setSpiedClass:object_getClass(that)];
                });
            }
        }
    }

    //NSLog(@"  Leaving forwardInvocation %@", invocation);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    __block NSMethodSignature *originalMethodSignature = nil;

    //NSLog(@"Spy (%p, %s) %s: %s", self, class_getName(object_getClass(self)), sel_getName(_cmd), sel_getName(sel));
    CDRSpy_as_spied_class(self, ^{
        originalMethodSignature = [self methodSignatureForSelector:sel];
    });
    //NSLog(@" Got method sig: %@", originalMethodSignature);

    return originalMethodSignature;
}

- (BOOL)respondsToSelector:(SEL)selector {
    __block BOOL respondsToSelector = NO;

    //NSLog(@"Spy (%p, %s) %s", self, class_getName(object_getClass(self)), sel_getName(_cmd));
    CDRSpy_as_spied_class(self, ^{
        respondsToSelector = [self respondsToSelector:selector];
    });

    return respondsToSelector;
}

- (void)doesNotRecognizeSelector:(SEL)selector {
    Class originalClass = [CDRSpyInfo publicClassForObject:self];
    NSString *exceptionReason = [NSString stringWithFormat:@"-[%@ %@]: unrecognized selector sent to spy %p", NSStringFromClass(originalClass), NSStringFromSelector(selector), self];
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:exceptionReason userInfo:nil];
}

#pragma mark - CedarDouble

- (BOOL)can_stub:(SEL)selector {
    return [self respondsToSelector:selector] && [self methodSignatureForSelector:selector];
}

- (Cedar::Doubles::StubbedMethod &)add_stub:(const Cedar::Doubles::StubbedMethod &)stubbed_method {
    return [CDRSpy_cedar_double_impl(self) add_stub:stubbed_method];
}

- (void)reject_method:(const Cedar::Doubles::RejectedMethod &)rejected_method {
    return [CDRSpy_cedar_double_impl(self) reject_method:rejected_method];
}

- (NSArray *)sent_messages {
    return CDRSpy_cedar_double_impl(self).sent_messages;
}

- (NSArray *)sent_messages_with_selector:(SEL)selector {
    return [CDRSpy_cedar_double_impl(self) sent_messages_with_selector:selector];
}

- (void)reset_sent_messages {
    NSLog(@"Resetting spy messages");
    [CDRSpy_cedar_double_impl(self) reset_sent_messages];
}

- (BOOL)has_stubbed_method_for:(SEL)selector {
    return [CDRSpy_cedar_double_impl(self) has_stubbed_method_for:selector];
}

- (BOOL)has_rejected_method_for:(SEL)selector {
    return [CDRSpy_cedar_double_impl(self) has_rejected_method_for:selector];
}

#pragma mark - Private

static CedarDoubleImpl *CDRSpy_cedar_double_impl(id self) {
    return [CDRSpyInfo cedarDoubleForObject:self];
}

static void CDRSpy_as_spied_class(id self, void(^block)(void)) {
    CDRSpyInfo *info = [CDRSpyInfo spyInfoForObject:self];
    if (info) {
        Class originalClass = info.spiedClass;
        if (originalClass != Nil) {
            Class spyClass = object_getClass(self);
            printf("Temporarily restoring %p\n", self);
            object_setClass(self, originalClass);

            @try {
                block();
            } @finally {
                if ([CDRSpyInfo spyInfoForObject:self] == info) {
                    object_setClass(self, spyClass);
                    printf("  %p is a spy again\n", self);
                }
            }
        }
    } else {
        // We aren't a spy anymore
        //NSLog(@"Invoking block after losing a spy status");
        block();
    }
}

static void CDRSpy_unsafe_as_spied_class(id self, void(^block)(void)) {
    CDRSpyInfo *info = [CDRSpyInfo spyInfoForObject:self];
    if (info) {
        Class originalClass = info.spiedClass;
        if (originalClass != Nil) {
            Class spyClass = object_getClass(self);
            printf("Temporarily restoring %p unsafely\n", self);
            object_setClass(self, originalClass);

            @try {
                block();
            } @finally {
                object_setClass(self, spyClass);
                printf("  %p is be a spy again\n", self);

            }
        }
    } else {
        //NSLog(@"Invoking block after losing a spy status");
        block();
    }
}

#pragma mark - GNUstep Compatibility
#ifdef __GNUSTEP_RUNTIME__
// Apple's NSProxy implements these, although it's not publicly declared as doing so

+ (BOOL)instancesRespondToSelector:(SEL)aSelector {
    return class_respondsToSelector(self, aSelector);
}

+ (BOOL)conformsToProtocol:(Protocol *)protocol {
    return protocol_isEqual(protocol, @protocol(NSObject)) || protocol_isEqual(protocol, @protocol(CedarDouble));
}

#endif

@end
