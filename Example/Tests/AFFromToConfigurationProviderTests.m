//
//  AFFromToConfigurationProviderTests.m
//  Paginator_Tests
//
//  Created by Антон Филимонов on 18/10/2017.
//  Copyright © 2017 Anton Filimonov. All rights reserved.
//

@import Paginator;
#import <XCTest/XCTest.h>
#import "GlobalTestConstants.h"

@interface AFFromToConfigurationProviderTests : XCTestCase

@property (strong, nonatomic) AFFromToPagingParametersProvider *pagingProvider;

@end

@implementation AFFromToConfigurationProviderTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.pagingProvider = [[AFFromToPagingParametersProvider alloc] initWithStartIndex:kLoadingStartIndex];
    self.pagingProvider.numerationStartIndex = kNumerationStartIndex;
}

- (void)tearDown {
    self.pagingProvider = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultParameterNames {
    NSDictionary<NSString *, NSNumber *> *parameters = [self.pagingProvider pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionForward];
    XCTAssertNotNil(parameters);
    XCTAssertEqual(parameters[@"from"].integerValue, kLoadingStartIndex);
    XCTAssertNotNil(parameters[@"to"]);
    XCTAssert(parameters.count == 2);
}

- (void)testCustomParameterNames {
    self.pagingProvider.fromParameterKey = @"start";
    self.pagingProvider.toParameterKey = @"end";
    NSDictionary<NSString *, NSNumber *> *parameters = [self.pagingProvider pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionForward];
    XCTAssertNotNil(parameters);
    XCTAssertEqual(parameters[@"start"].integerValue, kLoadingStartIndex);
    XCTAssertNotNil(parameters[@"end"]);
    XCTAssert(parameters.count == 2);
}

- (void)testAbilityToLoadPage {
    XCTAssertTrue([self.pagingProvider canLoadPageInDirection:AFPageLoadingDirectionForward]);
    XCTAssertTrue([self.pagingProvider canLoadPageInDirection:AFPageLoadingDirectionBackward]);
    
    [self.pagingProvider handlePageDataLoaded:[NSObject new]
                                forParameters:@{}
                                    direction:AFPageLoadingDirectionBackward
                            loadedItemsNumber:kLoadingStartIndex];
    XCTAssertFalse([self.pagingProvider canLoadPageInDirection:AFPageLoadingDirectionBackward]);
    [self.pagingProvider handlePageDataLoaded:[NSObject new]
                                forParameters:@{}
                                    direction:AFPageLoadingDirectionForward
                            loadedItemsNumber:kDefaultPageSize];
    XCTAssertTrue([self.pagingProvider canLoadPageInDirection:AFPageLoadingDirectionForward], @"Should be able to load more after successfully loaded page");
    
    [self.pagingProvider handlePageDataLoaded:[NSObject new]
                                forParameters:@{}
                                    direction:AFPageLoadingDirectionForward
                            loadedItemsNumber:0];
    XCTAssertFalse([self.pagingProvider canLoadPageInDirection:AFPageLoadingDirectionForward]);
}

- (void)testBackwardParametersCorrectnessPageSizeEqualStartIndex {
    self.pagingProvider.pageSize = kLoadingStartIndex;
    NSDictionary<NSString *, NSNumber *> *parameters = [self.pagingProvider pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionBackward];
    XCTAssertEqual(parameters[self.pagingProvider.fromParameterKey].integerValue, kNumerationStartIndex);
    XCTAssertEqual(parameters[self.pagingProvider.toParameterKey].integerValue, kLoadingStartIndex - 1);
}

- (void)testBackwardParametersCorrectnessPageSizeGreaterStartIndex {
    self.pagingProvider.pageSize = kLoadingStartIndex + 2;
    NSDictionary<NSString *, NSNumber *> *parameters = [self.pagingProvider pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionBackward];
    XCTAssertEqual(parameters[self.pagingProvider.fromParameterKey].integerValue, kNumerationStartIndex);
    XCTAssertEqual(parameters[self.pagingProvider.toParameterKey].integerValue, kLoadingStartIndex - 1);
}

- (void)testBackwardParametersCorrectnessPageSizeLessStartIndex {
    NSUInteger pageSize = kLoadingStartIndex - 2;
    self.pagingProvider.pageSize = pageSize;
    NSDictionary<NSString *, NSNumber *> *parameters = [self.pagingProvider pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionBackward];
    XCTAssertEqual(parameters[self.pagingProvider.fromParameterKey].integerValue, kLoadingStartIndex - pageSize);
    XCTAssertEqual(parameters[self.pagingProvider.toParameterKey].integerValue, kLoadingStartIndex - 1);
}

- (void)testMoreThanOnePageLoadBackwardParametersCorrectness {
    self.pagingProvider.pageSize = kPageSizeForTwoPagesTest;
    [self.pagingProvider handlePageDataLoaded:[NSObject new]
                                forParameters:@{}
                                    direction:AFPageLoadingDirectionBackward
                            loadedItemsNumber:kPageSizeForTwoPagesTest];
    NSDictionary<NSString *, NSNumber *> *parameters = [self.pagingProvider pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionBackward];
    XCTAssertEqual(parameters[self.pagingProvider.fromParameterKey].integerValue, kLoadingStartIndex - kPageSizeForTwoPagesTest * 2);
    XCTAssertEqual(parameters[self.pagingProvider.toParameterKey].integerValue, kLoadingStartIndex - kPageSizeForTwoPagesTest - 1 );
}

- (void)testForwardParametersCorrectness {
    self.pagingProvider.pageSize = kLoadingStartIndex;
    NSDictionary<NSString *, NSNumber *> *parameters = [self.pagingProvider pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionForward];
    XCTAssertEqual(parameters[self.pagingProvider.fromParameterKey].integerValue, kLoadingStartIndex);
    XCTAssertEqual(parameters[self.pagingProvider.toParameterKey].integerValue, kLoadingStartIndex * 2 - 1 );
}

- (void)testMoreThanOnePageLoadForwardParametersCorrectness {
    self.pagingProvider.pageSize = kPageSizeForTwoPagesTest;
    [self.pagingProvider handlePageDataLoaded:[NSObject new]
                                forParameters:@{}
                                    direction:AFPageLoadingDirectionForward
                            loadedItemsNumber:kPageSizeForTwoPagesTest];
    NSDictionary<NSString *, NSNumber *> *parameters = [self.pagingProvider pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionForward];
    XCTAssertEqual(parameters[self.pagingProvider.fromParameterKey].integerValue, kLoadingStartIndex + kPageSizeForTwoPagesTest);
    XCTAssertEqual(parameters[self.pagingProvider.toParameterKey].integerValue, kLoadingStartIndex + kPageSizeForTwoPagesTest * 2 - 1 );
}

- (void)testLoadInBothDirections {
    self.pagingProvider.pageSize = kPageSizeForTwoPagesTest;
    [self.pagingProvider handlePageDataLoaded:[NSObject new]
                                forParameters:@{}
                                    direction:AFPageLoadingDirectionForward
                            loadedItemsNumber:kPageSizeForTwoPagesTest];
    [self.pagingProvider handlePageDataLoaded:[NSObject new]
                                forParameters:@{}
                                    direction:AFPageLoadingDirectionBackward
                            loadedItemsNumber:kPageSizeForTwoPagesTest];
    
    NSDictionary<NSString *, NSNumber *> *parametersBackward = [self.pagingProvider pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionBackward];
    XCTAssertEqual(parametersBackward[self.pagingProvider.fromParameterKey].integerValue, kLoadingStartIndex - kPageSizeForTwoPagesTest * 2);
    XCTAssertEqual(parametersBackward[self.pagingProvider.toParameterKey].integerValue, kLoadingStartIndex - kPageSizeForTwoPagesTest - 1 );
    
    NSDictionary<NSString *, NSNumber *> *parametersForward = [self.pagingProvider pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionForward];
    XCTAssertEqual(parametersForward[self.pagingProvider.fromParameterKey].integerValue, kLoadingStartIndex + kPageSizeForTwoPagesTest);
    XCTAssertEqual(parametersForward[self.pagingProvider.toParameterKey].integerValue, kLoadingStartIndex + kPageSizeForTwoPagesTest * 2 - 1 );
}

- (void)testNilRequestWhenCantLoadMore {
    [self.pagingProvider handlePageDataLoaded:[NSObject new]
                                forParameters:@{}
                                    direction:AFPageLoadingDirectionBackward
                            loadedItemsNumber:kLoadingStartIndex];
    XCTAssertNil([self.pagingProvider pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionBackward]);
}

@end
