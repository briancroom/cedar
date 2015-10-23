#import <Foundation/Foundation.h>
#import "CedarObservedObject.h"

#define CDR_SUPPORT_HAS_ORDERED_SET __APPLE__

@interface ObjectWithCollections : NSObject <CedarObservedObject>

@property (retain, nonatomic) NSMutableArray *array;
@property (retain, nonatomic) NSMutableSet *set;
@property (retain, nonatomic) NSMutableArray *manualArray;
@property (retain, nonatomic) NSMutableSet *manualSet;

#if CDR_SUPPORT_HAS_ORDERED_SET
@property (retain, nonatomic) NSMutableOrderedSet *orderedSet;
#endif

@end
