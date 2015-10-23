include $(GNUSTEP_MAKEFILES)/common.make

TOOL_NAME = CedarSpecs

CedarSpecs_OBJC_FILES = Support/ArgumentReleaser.m \
	Support/DeallocNotifier.m \
	Support/FibonacciCalculator.m \
	Support/FooSuperclass.m \
	Support/ObjectWithCollections.m \
	Support/ObjectWithForwardingTarget.m \
	Support/ObjectWithProperty.m \
	Support/ObjectWithValueEquality.m \
	Support/ObjectWithWeakDelegate.m \
	Support/SimpleIncrementer.m \
	Support/SimpleKeyValueObserver.m

CedarSpecs_OBJCC_FILES = main.mm \
	SpecSpec.mm \
	CDRNilSpec.mm \
	CDRSpecFailureSpec.mm \
	CDRTypeUtilitiesSpec.mm \
	GlobalBeforeEachSpec.mm \
	ObjCHeadersSpec.mm \
	ShouldSyntaxSpec.mm \
	Doubles/CDRClassFakeSpec.mm \
	Doubles/CDRProtocolFakeSpec.mm \
	Doubles/CDRSpySpec.mm \
	Doubles/CedarDoubleARCSharedExamples.mm \
	Doubles/CedarDoubleSharedExamples.mm \
	Doubles/CedarNiceFakeSharedExamples.mm \
	Doubles/CedarOrdinaryFakeSharedExamples.mm \
	Matchers/ExpectFailureWithMessage.mm \
	Matchers/Base/BeCloseToSpec.mm \
	Matchers/Base/BeFalsySpec.mm \
	Matchers/Base/BeInstanceOfSpec.mm \
	Matchers/Base/BeNilSpec.mm \
	Matchers/Base/BeNil_ARCSpec.mm \
	Matchers/Base/ExistSpec.mm \
	Matchers/Base/BeSameInstanceAsSpec.mm \
	Matchers/Base/BeSameInstanceAs_ARCSpec.mm \
	Matchers/Base/BeTruthySpec.mm \
	Matchers/Base/ConformToSpec.mm \
	Matchers/Base/EqualSpec.mm \
	Matchers/Base/MutableEqualSpec.mm \
	Matchers/Base/RaiseExceptionSpec.mm \
	Matchers/Base/RespondToSpec.mm \
	Matchers/Container/BeEmptySpec.mm \
	Matchers/Container/ContainSpec.mm \
	Reporters/CDRDefaultReporterSpec.mm \
	Support/ExampleWithPublicRunDates.mm \





#	CDRSpecSpec.mm \
	#CDRExampleSpec.mm \
#	CDRExampleGroupSpec.mm \

	
#	CDRSymbolicatorSpec.mm \

#	Matchers/Base/BeGreaterThanSpec.mm \
#	Matchers/Base/BeGTESpec.mm \
#	Matchers/Base/BeLessThanSpec.mm \
#	Matchers/Base/BeLTESpec.mm \
	
#	Doubles/HaveReceivedSpec.mm \



Doubles/CedarDoubleARCSharedExamples.mm_FILE_FLAGS = -fobjc-arc
Matchers/Base/BeNil_ARCSpec.mm_FILE_FLAGS = -fobjc-arc
Matchers/Base/BeSameInstanceAs_ARCSpec.mm_FILE_FLAGS = -fobjc-arc
Support/ObjectWithWeakDelegate.m_FILE_FLAGS = -fobjc-arc

ADDITIONAL_INCLUDE_DIRS = -I../Source/Headers/Public \
	-I../Source/Headers/Public/Doubles \
	-I../Source/Headers/Public/Doubles/Arguments \
	-I../Source/Headers/Public/Matchers \
	-I../Source/Headers/Public/Matchers/Base \
	-I../Source/Headers/Public/Matchers/Comparators \
	-I../Source/Headers/Public/Matchers/Container \
	-I../Source/Headers/Public/Matchers/Stringifiers \
	-I../Source/Headers/Public/Reporters \
	-I../Source/Headers/Project \
	-I../Source/Headers/Project/Doubles \
	-I../Source/Headers/Project/Extensions \
	-I../Source/Headers/Project/ReporterHelpers \
	-I../Source/Headers/Project/Reporters \
	-ISupport \
	-IMatchers
ADDITIONAL_LIB_DIRS = -L../obj

# The --whole-archive linker flag is equivalent to -all_load on OS X. It needs to be 
# enabled just for libCedar in order for Cedar's categories to get included
CedarSpecs_TOOL_LIBS += -Wl,-whole-archive -lCedar -Wl,-no-whole-archive -ldispatch
ADDITIONAL_OBJCCFLAGS = -std=c++11
ADDITIONAL_OBJC_LIBS = -lobjcxx
#ADDITIONAL_LDFLAGS = -Wl,-whole-archive

include $(GNUSTEP_MAKEFILES)/tool.make