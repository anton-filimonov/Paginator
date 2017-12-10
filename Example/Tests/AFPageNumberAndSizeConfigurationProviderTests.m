//
//  AFPageNumberAndSizeConfigurationProviderTests.m
//  Paginator_Tests
//
//  Created by Anton Filimonov on 20/10/2017.
//

@import AFPaginator;
#import <XCTest/XCTest.h>
#import "GlobalTestConstants.h"

static const NSUInteger kLoadingStartPageNumber = 2;

@interface AFPageNumberAndSizeConfigurationProviderTests : XCTestCase

@property (strong, nonatomic) AFPageNumberAndSizePagingParametersProvider *pagingProvider;

@end

@implementation AFPageNumberAndSizeConfigurationProviderTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.pagingProvider = [[AFPageNumberAndSizePagingParametersProvider alloc] initWithStartIndex:kLoadingStartPageNumber];
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
    XCTAssertEqual(parameters[@"pageNumber"].integerValue, kLoadingStartPageNumber);
    XCTAssertEqual(parameters[@"pageSize"].integerValue, kDefaultPageSize);
    XCTAssert(parameters.count == 2);
}

- (void)testCustomParameterNames {
    self.pagingProvider.pageSizeParameterKey = @"size";
    self.pagingProvider.pageNumberParameterKey = @"page";
    
    NSDictionary<NSString *, NSNumber *> *parameters = [self.pagingProvider pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionForward];
    
    XCTAssertNotNil(parameters);
    XCTAssertEqual(parameters[@"page"].integerValue, kLoadingStartPageNumber);
    XCTAssertEqual(parameters[@"size"].integerValue, kDefaultPageSize);
    XCTAssert(parameters.count == 2);
}

- (void)testAbilityToLoadPage {
    XCTAssertTrue([self.pagingProvider canLoadPageInDirection:AFPageLoadingDirectionForward]);
    
    for (NSUInteger i = kLoadingStartPageNumber; i > kNumerationStartIndex; --i) {
        XCTAssertTrue([self.pagingProvider canLoadPageInDirection:AFPageLoadingDirectionBackward]);
        [self.pagingProvider handlePageDataLoaded:[NSObject new]
                                    forParameters:@{}
                                        direction:AFPageLoadingDirectionBackward
                                loadedItemsNumber:kDefaultPageSize];
    }
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

- (void)testBackwardParametersCorrectness {
    NSDictionary<NSString *, NSNumber *> *parameters = [self.pagingProvider pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionBackward];
    XCTAssertEqual(parameters[self.pagingProvider.pageNumberParameterKey].integerValue, kLoadingStartPageNumber - 1);
    XCTAssertEqual(parameters[self.pagingProvider.pageSizeParameterKey].integerValue, kDefaultPageSize);
}

- (void)testMoreThanOnePageLoadBackwardParametersCorrectness {
    [self.pagingProvider handlePageDataLoaded:[NSObject new]
                                forParameters:@{}
                                    direction:AFPageLoadingDirectionBackward
                            loadedItemsNumber:kDefaultPageSize];
    NSDictionary<NSString *, NSNumber *> *parameters = [self.pagingProvider pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionBackward];
    XCTAssertEqual(parameters[self.pagingProvider.pageNumberParameterKey].integerValue, kLoadingStartPageNumber - 2);
    XCTAssertEqual(parameters[self.pagingProvider.pageSizeParameterKey].integerValue, kDefaultPageSize);
}

- (void)testForwardParametersCorrectness {
    NSDictionary<NSString *, NSNumber *> *parameters = [self.pagingProvider pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionForward];
    XCTAssertEqual(parameters[self.pagingProvider.pageNumberParameterKey].integerValue, kLoadingStartPageNumber);
    XCTAssertEqual(parameters[self.pagingProvider.pageSizeParameterKey].integerValue, kDefaultPageSize);
}

- (void)testMoreThanOnePageLoadForwardParametersCorrectness {
    [self.pagingProvider handlePageDataLoaded:[NSObject new]
                                forParameters:@{}
                                    direction:AFPageLoadingDirectionForward
                            loadedItemsNumber:kDefaultPageSize];
    NSDictionary<NSString *, NSNumber *> *parameters = [self.pagingProvider pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionForward];
    XCTAssertEqual(parameters[self.pagingProvider.pageNumberParameterKey].integerValue, kLoadingStartPageNumber + 1);
    XCTAssertEqual(parameters[self.pagingProvider.pageSizeParameterKey].integerValue, kDefaultPageSize);
}

- (void)testLoadInBothDirections {
    [self.pagingProvider handlePageDataLoaded:[NSObject new]
                                forParameters:@{}
                                    direction:AFPageLoadingDirectionForward
                            loadedItemsNumber:kDefaultPageSize];
    [self.pagingProvider handlePageDataLoaded:[NSObject new]
                                forParameters:@{}
                                    direction:AFPageLoadingDirectionBackward
                            loadedItemsNumber:kDefaultPageSize];
    
    NSDictionary<NSString *, NSNumber *> *parametersBackward = [self.pagingProvider pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionBackward];
    XCTAssertEqual(parametersBackward[self.pagingProvider.pageNumberParameterKey].integerValue, kLoadingStartPageNumber - 2);
    XCTAssertEqual(parametersBackward[self.pagingProvider.pageSizeParameterKey].integerValue, kDefaultPageSize);
    
    NSDictionary<NSString *, NSNumber *> *parametersForward = [self.pagingProvider pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionForward];
    XCTAssertEqual(parametersForward[self.pagingProvider.pageNumberParameterKey].integerValue, kLoadingStartPageNumber + 1);
    XCTAssertEqual(parametersForward[self.pagingProvider.pageSizeParameterKey].integerValue, kDefaultPageSize);
}

- (void)testNilRequestWhenCantLoadMore {
    for (NSUInteger i = kLoadingStartPageNumber; i > kNumerationStartIndex; --i) {
        [self.pagingProvider handlePageDataLoaded:[NSObject new]
                                    forParameters:@{}
                                        direction:AFPageLoadingDirectionBackward
                                loadedItemsNumber:kDefaultPageSize];
    }
    XCTAssertNil([self.pagingProvider pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionBackward]);
}

@end
