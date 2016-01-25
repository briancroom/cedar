#import "HaveReceived.h"
#import "NSInvocation+Cedar.h"
#import "CDRSpyInfo.h"

namespace Cedar { namespace Doubles {

    NSString * recorded_invocations_message(NSArray *recordedInvocations) {
        NSMutableString *message = [NSMutableString string];

        for (NSInvocation *invocation in recordedInvocations) {
            [message appendFormat:@"  %@", NSStringFromSelector(invocation.selector)];
            NSArray *arguments = [invocation cdr_arguments];
            if (arguments.count) {
                [message appendFormat:@"<%@>", [arguments componentsJoinedByString:@", "]];
            }
            [message appendString:@"\n"];
        }

        return message;
    }

    void verify_object_is_a_double(id instance) {
        Class clazz = object_getClass(instance);
        if (![clazz instancesRespondToSelector:@selector(sent_messages)] && [CDRSpyInfo spyInfoForObject:instance] == nil) {
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Received expectation for non-double object <%@>", instance]
                                       userInfo:nil] raise];
        }
    }
}}
