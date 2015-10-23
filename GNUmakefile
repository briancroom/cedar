include $(GNUSTEP_MAKEFILES)/common.make

LIBRARY_NAME = libCedar

libCedar_HEADER_FILES_INSTALL_DIR = Cedar
libCedar_HEADER_FILES_DIR = Source/Headers/Public
libCedar_HEADER_FILES = CDRExampleBase.h \
	CDRExampleGroup.h \
	CDRExample.h \
	CDRExampleParent.h \
	CDRFunctions.h \
	CDRHooks.h \
	CDRSharedExampleGroupPool.h \
	CDRSpecFailure.h \
	CDRSpec.h \
	CDRSpecHelper.h \
	CDRVersion.h \
	Cedar.h \
	Doubles/CDRClassFake.h \
	Doubles/CDRFake.h \
	Doubles/CDRProtocolFake.h \
	Doubles/CDRSpy.h \
	Doubles/CedarDouble.h \
	Doubles/CedarDoubles.h \
	Doubles/HaveReceived.h \
	Doubles/InvocationMatcher.h \
	Doubles/RejectedMethod.h \
	Doubles/StubbedMethod.h \
	Doubles/Arguments/AnyArgument.h \
	Doubles/Arguments/AnyInstanceArgument.h \
	Doubles/Arguments/AnyInstanceConformingToProtocolArgument.h \
	Doubles/Arguments/AnyInstanceOfClassArgument.h \
	Doubles/Arguments/Argument.h \
	Doubles/Arguments/ReturnValue.h \
	Doubles/Arguments/ValueArgument.h \
	Matchers/ActualValue.h \
	Matchers/CedarComparators.h \
	Matchers/CedarMatchers.h \
	Matchers/CedarStringifiers.h \
	Matchers/ShouldSyntax.h \
	Matchers/Base/Base.h \
	Matchers/Base/BeCloseTo.h \
	Matchers/Base/BeFalsy.h \
	Matchers/Base/BeGreaterThan.h \
	Matchers/Base/BeGTE.h \
	Matchers/Base/BeInstanceOf.h \
	Matchers/Base/BeLessThan.h \
	Matchers/Base/BeLTE.h \
	Matchers/Base/BeNil.h \
	Matchers/Base/BeSameInstanceAs.h \
	Matchers/Base/BeTruthy.h \
	Matchers/Base/ConformTo.h \
	Matchers/Base/Equal.h \
	Matchers/Base/Exist.h \
	Matchers/Base/RaiseException.h \
	Matchers/Base/RespondTo.h \
	Matchers/Comparators/AnInstanceOf.h \
	Matchers/Comparators/ComparatorsBase.h \
	Matchers/Comparators/ComparatorsContainerConvenience.h \
	Matchers/Comparators/ComparatorsContainer.h \
	Matchers/Comparators/CompareCloseTo.h \
	Matchers/Comparators/CompareEqual.h \
	Matchers/Comparators/CompareGreaterThan.h \
	Matchers/Container/BeEmpty.h \
	Matchers/Container/Contain.h \
	Matchers/Stringifiers/StringifiersBase.h \
	Matchers/Stringifiers/StringifiersContainer.h \
	Reporters/CDRBufferedDefaultReporter.h \
	Reporters/CDRColorizedReporter.h \
	Reporters/CDRDefaultReporter.h \
	Reporters/CDRExampleReporter.h \
	Reporters/CDRJUnitXMLReporter.h \
	Reporters/CDROTestReporter.h \
	Reporters/CDRTeamCityReporter.h \

libCedar_OBJC_FILES = Source/CDRExampleBase.m \
	Source/CDRExampleGroup.m \
	Source/CDRExample.m \
	Source/CDRFunctions.m \
	Source/CDRNil.m \
	Source/CDRRuntimeUtilities.m \
	Source/CDRSharedExampleGroupPool.m \
	Source/CDRSpecFailure.m \
	Source/CDRSpecHelper.m \
	Source/CDRSpec.m \
	Source/CDRSpecRun.m \
	Source/CDRSymbolicator.m \
	Source/CDRTypeUtilities.m \
	Source/Extensions/NSInvocation+Cedar.m \
	Source/Extensions/NSMethodSignature+Cedar.m \
	Source/ReporterHelpers/CDROTestNamer.m \
	Source/ReporterHelpers/CDRSlowTestStatistics.m \
	Source/Reporters/CDRBufferedDefaultReporter.m \
	Source/Reporters/CDRColorizedReporter.m \
	Source/Reporters/CDRDefaultReporter.m \
	Source/Reporters/CDRJUnitXMLReporter.m \
	Source/Reporters/CDROTestReporter.m \
	Source/Reporters/CDRReportDispatcher.m \
	Source/Reporters/CDRTeamCityReporter.m

libCedar_OBJCC_FILES = Source/Matchers/Base/ConformTo.mm \
	Source/Matchers/Base/RaiseException.mm \
	Source/Matchers/Base/RespondTo.mm \
	Source/Matchers/Stringifiers/StringifiersBase.mm \
	Source/Doubles/CDRClassFake.mm \
	Source/Doubles/CDRFake.mm \
	Source/Doubles/CDRProtocolFake.mm \
	Source/Doubles/CDRSpyInfo.mm \
	Source/Doubles/CDRSpy.mm \
	Source/Doubles/CedarDoubleImpl.mm \
	Source/Doubles/CedarDouble.mm \
	Source/Doubles/HaveReceived.mm \
	Source/Doubles/InvocationMatcher.mm \
	Source/Doubles/RejectedMethod.mm \
	Source/Doubles/StubbedMethod.mm \
	Source/Doubles/Arguments/AnyArgument.mm \
	Source/Doubles/Arguments/AnyInstanceArgument.mm \
	Source/Doubles/Arguments/AnyInstanceConformingToProtocolArgument.mm \
	Source/Doubles/Arguments/AnyInstanceOfClassArgument.mm

ADDITIONAL_INCLUDE_DIRS = -ISource/Headers/Public \
	-ISource/Headers/Public/Doubles \
	-ISource/Headers/Public/Doubles/Arguments \
	-ISource/Headers/Public/Matchers \
	-ISource/Headers/Public/Matchers/Base \
	-ISource/Headers/Public/Matchers/Comparators \
	-ISource/Headers/Public/Matchers/Container \
	-ISource/Headers/Public/Matchers/Stringifiers \
	-ISource/Headers/Public/Reporters \
	-ISource/Headers/Project \
	-ISource/Headers/Project/Doubles \
	-ISource/Headers/Project/Extensions \
	-ISource/Headers/Project/ReporterHelpers \
	-ISource/Headers/Project/Reporters
ADDITIONAL_OBJCCFLAGS = -std=c++11

include $(GNUSTEP_MAKEFILES)/library.make

CEDAR_HEADERS_DIR = $(GNUSTEP_$(GNUSTEP_INSTALLATION_DOMAIN)_HEADERS)/$(libCedar_HEADER_FILES_INSTALL_DIR)

after-install::
	@(echo " Flattening Header Directory Tree...")
	@(find $(CEDAR_HEADERS_DIR) -mindepth 2 -type f -exec mv '{}' $(CEDAR_HEADERS_DIR) ';')
	@(find $(CEDAR_HEADERS_DIR) -mindepth 1 -type d -delete)

after-uninstall::
	rm -rf $(CEDAR_HEADERS_DIR)
