#define EXPOSE_NSInvocation_IVARS 1
#import "NSInvocation+Cedar.h"
#import "NSMethodSignature+Cedar.h"
#import "CDRBlockHelper.h"
#import "CDRTypeUtilities.h"
#import <objc/runtime.h>

static char COPIED_BLOCKS_KEY;

@implementation NSInvocation (Cedar)

- (void)cdr_copyBlockArguments {
    static char *blockTypeEncoding = "@?";
    NSMethodSignature *methodSignature = [self methodSignature];
    NSUInteger numberOfArguments = [methodSignature numberOfArguments];
    NSMutableArray *copiedBlocks = [NSMutableArray array];

    for (NSUInteger argumentIndex = 2; argumentIndex < numberOfArguments; ++argumentIndex) {
        const char *encoding = [methodSignature getArgumentTypeAtIndex:argumentIndex];
        if (strncmp(blockTypeEncoding, encoding, 2) == 0) {
            id argument = nil;
            [self getArgument:&argument atIndex:argumentIndex];
            if (argument) {
                argument = [argument copy];
                [copiedBlocks addObject:argument];
                [argument release];
                [self setArgument:&argument atIndex:argumentIndex];
            }
        }
    }

    objc_setAssociatedObject(self, &COPIED_BLOCKS_KEY, copiedBlocks, OBJC_ASSOCIATION_RETAIN);
}

- (NSInvocation *)cdr_invocationWithoutCmdArgument {
    NSMethodSignature *methodSignature = [self methodSignature];
    NSMethodSignature *adjustedMethodSignature = [methodSignature cdr_signatureWithoutSelectorArgument];
    NSInvocation *adjustedInvocation = [NSInvocation invocationWithMethodSignature:adjustedMethodSignature];

    NSInteger adjustedArgIndex = 0;
    for (NSInteger argIndex = 0; argIndex < [methodSignature numberOfArguments]; argIndex++) {
        if (argIndex == 1) { continue; }

        NSUInteger size;
        NSGetSizeAndAlignment([methodSignature getArgumentTypeAtIndex:argIndex], &size, NULL);
        char argBuffer[size];

        [self getArgument:argBuffer atIndex:argIndex];
        [adjustedInvocation setArgument:argBuffer atIndex:adjustedArgIndex];

        adjustedArgIndex++;
    }

    return adjustedInvocation;
}

- (void)cdr_invokeUsingBlockWithoutSelfArgument:(id)block {
    NSInvocation *adjustedInvocation = [self cdr_invocationWithoutCmdArgument];

    [adjustedInvocation setTarget:block];
    struct Block_literal *blockLiteral = (struct Block_literal *)block;
    [adjustedInvocation invokeUsingIMP:(IMP)blockLiteral->invoke];

    NSUInteger returnValueSize = [[self methodSignature] methodReturnLength];
    if (returnValueSize > 0) {
        char returnValueBuffer[returnValueSize];
        [adjustedInvocation getReturnValue:&returnValueBuffer];
        [self setReturnValue:&returnValueBuffer];
    }
}

- (NSArray *)cdr_arguments {
    NSMutableArray *args = [NSMutableArray array];
    NSMethodSignature *methodSignature = [self methodSignature];
    for (NSInteger argIndex = 2; argIndex < [methodSignature numberOfArguments]; argIndex++) {
        NSUInteger size;
        NSGetSizeAndAlignment([methodSignature getArgumentTypeAtIndex:argIndex], &size, NULL);
        char argBuffer[size];
        memset(argBuffer, (int)sizeof(argBuffer), sizeof(char));
        [self getArgument:argBuffer atIndex:argIndex];

        const char *argType = [methodSignature getArgumentTypeAtIndex:argIndex];
        [args addObject:[CDRTypeUtilities boxedObjectOfBytes:argBuffer ofObjCType:argType]];
    }
    return args;
}

- (void)cdr_clearReturnValue {
    NSUInteger returnValueSize = [[self methodSignature] methodReturnLength];
    if (returnValueSize > 0) {
        char returnValueBuffer[returnValueSize];
        memset(returnValueBuffer, 0, returnValueSize);
        [self setReturnValue:&returnValueBuffer];
    }
}

@end


#ifdef __GNUSTEP_RUNTIME__

@interface GSFFCallInvocation : NSInvocation @end
@interface GSFFIInvocation : NSInvocation @end

@implementation GSFFCallInvocation (InvokeUsingIMP)
extern void GSFFCallInvokeWithTargetAndImp(NSInvocation *inv, id anObject, IMP imp) __attribute__((weak));

// Based on portions of -[GSFFCallInvocation invokeWithTarget:]
- (void)invokeUsingIMP:(IMP)imp {
    const char *type = self.methodSignature.methodReturnType;

    GSFFCallInvokeWithTargetAndImp(self, self.target, imp);

    if (strchr(type, _C_ID) != NULL) {
        [*(id *)_retval retain];
    }

    _validReturn = YES;
}

@end

@implementation GSFFIInvocation (InvokeUsingIMP)
extern void GSFFIInvokeWithTargetAndImp(NSInvocation *inv, id anObject, IMP imp) __attribute__((weak));
extern BOOL cifframe_decode_arg (const char *type, void* buffer);

// Based on portions of -[GSFFIInvocation invokeWithTarget:]
- (void)invokeUsingIMP:(IMP)imp {
    const char *type = self.methodSignature.methodReturnType;

    GSFFIInvokeWithTargetAndImp(self, self.target, imp);
    if (strchr(type, _C_VOID) == NULL) {
        cifframe_decode_arg(type, _retval);
    }

    if (strchr(type, _C_ID) != NULL) {
        [*(id *)_retval retain];
    }

    _validReturn = YES;
}

@end

#endif
