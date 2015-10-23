#import <Foundation/Foundation.h>
#import "CedarObservedObject.h"

@interface ObjectWithProperty : NSObject <CedarObservedObject>

@property (nonatomic, assign) float floatProperty;
@property (nonatomic, assign) float manualFloatProperty;

@end
