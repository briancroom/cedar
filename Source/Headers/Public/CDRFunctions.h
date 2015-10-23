#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

NSArray *CDRReportersFromEnv(const char*defaultReporterClassName);

int CDRRunSpecs();
void CDRInjectIntoXCTestRunner();
int CDRRunSpecsWithCustomExampleReporters(NSArray *reporters);
NSArray *CDRShuffleItemsInArrayWithSeed(NSArray *sortedItems, unsigned int seed);
NSArray *CDRReportersToRun();
NSString *CDRGetTestBundleExtension();
void CDRSuppressStandardPipesWhileLoadingClasses();

#ifdef __cplusplus
}
#endif
