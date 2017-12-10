//
//  AFPaginatorTests.m
//  Paginator_Tests
//
//  Created by Anton Filimonov on 24/10/2017.
//

@import AFPaginator;

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

@interface AFPaginatorTests : XCTestCase

@property (strong, nonatomic) AFPaginator *paginator;
@property (strong, nonatomic) id<AFPagingParametersProvider> pagingProviderMock;
@property (strong, nonatomic) id<AFDataRequestHandler> requestHandlerMock;

@property (strong, nonatomic, readonly) NSDictionary *kConfigurationStub;

@end

@implementation AFPaginatorTests

- (NSDictionary *)kConfigurationStub {
    return @{@"from": @1, @"to": @2};
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.pagingProviderMock = OCMProtocolMock(@protocol(AFPagingParametersProvider));
    self.requestHandlerMock = OCMProtocolMock(@protocol(AFDataRequestHandler));
    self.paginator = [[AFPaginator alloc] initWithPagingParametersProvider:self.pagingProviderMock
                                                            requestHandler:self.requestHandlerMock];
}

- (void)tearDown {
    self.pagingProviderMock =  nil;
    self.requestHandlerMock = nil;
    self.paginator = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatRequestHandlerReceivesTheObjectCreatedByPagingParametersProvider {
    //given
    OCMStub([self.pagingProviderMock pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionForward]).andReturn(self.kConfigurationStub);
    OCMStub([self.pagingProviderMock canLoadPageInDirection:AFPageLoadingDirectionForward]).andReturn(YES);
    
    //when
    XCTAssertTrue([self.paginator loadPageInDirection:AFPageLoadingDirectionForward]);
    
    //then
    OCMVerify([self.requestHandlerMock sendRequestWithConfiguration:self.kConfigurationStub completion:[OCMArg any]]);
}

- (void)testThatRequestHandlerReceivesTheObjectCreatedByConfigurationBuilder {
    //given
    static NSString *const customConfiguration = @"Custom Configuration";
    OCMStub([self.pagingProviderMock pagingParametersForLoadingNextPageInDirection:AFPageLoadingDirectionForward]).andReturn(self.kConfigurationStub);
    OCMStub([self.pagingProviderMock canLoadPageInDirection:AFPageLoadingDirectionForward]).andReturn(YES);
    self.paginator.requestConfigurationBuilder = ^(NSDictionary *pagingParameters) {
        return customConfiguration;
    };
    
    //when
    XCTAssertTrue([self.paginator loadPageInDirection:AFPageLoadingDirectionForward]);
    
    //then
    OCMVerify([self.requestHandlerMock sendRequestWithConfiguration:customConfiguration
                                                         completion:[OCMArg any]]);
}

- (void)testThatCantStartNewLoadWhenInProgressForDirection {
    //given
    OCMStub([self.pagingProviderMock canLoadPageInDirection:AFPageLoadingDirectionForward]).andReturn(YES);
    
    //then
    XCTAssertTrue([self.paginator loadPageInDirection:AFPageLoadingDirectionForward], @"First call should be successfull, cause no loading started yet");
    XCTAssertFalse([self.paginator loadPageInDirection:AFPageLoadingDirectionForward], @"Loading page forward is in progress now, so trying to load more pages in same direction should fail");
}

- (void)testThatCanStartAtLeastOneLoadingForEveryDirection {
    //given
    OCMStub([self.pagingProviderMock canLoadPageInDirection:AFPageLoadingDirectionForward]).andReturn(YES).ignoringNonObjectArgs;
    
    //then
    XCTAssertTrue([self.paginator loadPageInDirection:AFPageLoadingDirectionForward]);
    XCTAssertTrue([self.paginator loadPageInDirection:AFPageLoadingDirectionBackward]);
}

- (void)testCanLoadWhenPagingProviderReturnsTrue {
    //given
    OCMStub([self.pagingProviderMock canLoadPageInDirection:AFPageLoadingDirectionForward]).andReturn(YES).ignoringNonObjectArgs;
    
    //then
    XCTAssertTrue([self.paginator canLoadInDirection:AFPageLoadingDirectionForward]);
    XCTAssertTrue([self.paginator canLoadInDirection:AFPageLoadingDirectionBackward]);
}

- (void)testCantLoadWhenPagingProviderReturnsFalse {
    //given
    OCMStub([self.pagingProviderMock canLoadPageInDirection:AFPageLoadingDirectionForward]).andReturn(NO).ignoringNonObjectArgs;
    
    //then
    XCTAssertFalse([self.paginator canLoadInDirection:AFPageLoadingDirectionForward]);
    XCTAssertFalse([self.paginator canLoadInDirection:AFPageLoadingDirectionBackward]);
}

- (void)testCanLoadAgainAfterLoadingFinish {
    //given
    OCMStub([self.pagingProviderMock canLoadPageInDirection:AFPageLoadingDirectionForward]).andReturn(YES);
    OCMStub([self.requestHandlerMock sendRequestWithConfiguration:[OCMArg any]
                                                       completion:([OCMArg invokeBlockWithArgs:[NSArray array], [NSNull null], nil])]);
    
    //when
    XCTAssertTrue([self.paginator loadPageInDirection:AFPageLoadingDirectionForward]);
    
    //then
    XCTAssertTrue([self.paginator loadPageInDirection:AFPageLoadingDirectionForward], @"should be able to request next page, cause request handling finished");
}

- (void)testPreprocessingBlockIsCalledWithCorrectParamsAndSynchronously {
    //given
    NSArray *loadResult = @[@1, @2, @4];
    __block BOOL blockIsCalled = NO;
    __weak typeof(self) wself = self; // to avoid warning for implicit capturing self in block
    self.paginator.dataPreprocessingBlock = ^NSArray * _Nonnull(id  _Nonnull loadedData, NSError * _Nullable __autoreleasing * _Nullable error) {
        typeof(wself) self = wself;
        XCTAssertEqualObjects(loadResult, loadedData);
        XCTAssertNotEqual(error, NULL);
        blockIsCalled = YES;
        return @[];
    };
    OCMStub([self.pagingProviderMock canLoadPageInDirection:AFPageLoadingDirectionForward]).andReturn(YES);
    OCMStub([self.requestHandlerMock sendRequestWithConfiguration:[OCMArg any]
                                                       completion:([OCMArg invokeBlockWithArgs:loadResult, [NSNull null], nil])]);
    
    
    //when
    XCTAssertTrue([self.paginator loadPageInDirection:AFPageLoadingDirectionForward]);
    
    //then
    XCTAssertTrue(blockIsCalled, @"Data preprocessing block is not called");
}

- (void)testPreprocessingBlockIsNotCalledWhenRequestReturnsError {
    //given
    NSError *loadError = [NSError errorWithDomain:@"TestErrorDomain" code:1 userInfo:nil];
    __block BOOL blockIsCalled = NO;
    self.paginator.dataPreprocessingBlock = ^NSArray * _Nonnull(id  _Nonnull loadedData, NSError * _Nullable __autoreleasing * _Nullable error) {
        blockIsCalled = YES;
        return @[];
    };
    OCMStub([self.pagingProviderMock canLoadPageInDirection:AFPageLoadingDirectionForward]).andReturn(YES);
    OCMStub([self.requestHandlerMock sendRequestWithConfiguration:[OCMArg any]
                                                       completion:([OCMArg invokeBlockWithArgs:[NSNull null], loadError, nil])]);
    
    
    //when
    XCTAssertTrue([self.paginator loadPageInDirection:AFPageLoadingDirectionForward]);
    
    //then
    XCTAssertFalse(blockIsCalled, @"Data preprocessing block is called when error received from request handler");
}

#pragma mark - Async Tests
- (void)testThatDelegateSuccessMethodCalledOnSuccessfullLoadWithCorrectParams {
    //given
    NSArray *loadResult = @[@1, @2, @4];
    OCMStub([self.pagingProviderMock canLoadPageInDirection:AFPageLoadingDirectionForward]).andReturn(YES);
    OCMStub([self.requestHandlerMock sendRequestWithConfiguration:[OCMArg any]
                                                       completion:([OCMArg invokeBlockWithArgs:loadResult, [NSNull null], nil])]);
    id<AFPaginatorDelegate> delegateMock = OCMProtocolMock(@protocol(AFPaginatorDelegate));
    XCTestExpectation *delegateExpectation = [self expectationWithDescription:@"Delegate method call expectation"];
    OCMReject([delegateMock paginator:[OCMArg any] didFailPageLoadingWithError:[OCMArg any] inDirection:0]).ignoringNonObjectArgs;
    OCMStub([delegateMock paginator:self.paginator
                        didLoadPage:loadResult
                        inDirection:AFPageLoadingDirectionForward])
    .andDo(^(NSInvocation *invocation) {
        [delegateExpectation fulfill];
    });
    self.paginator.delegate = delegateMock;
    
    
    //when
    XCTAssertTrue([self.paginator loadPageInDirection:AFPageLoadingDirectionForward]);
    
    //then
    [self waitForExpectations:@[delegateExpectation] timeout:0.1];
}

- (void)testThatResultIsWhatPreprocessingBlockReturns {
    //given
    NSArray *loadResult = @[@1, @2, @4];
    NSArray *preprocessingResult = @[@5, @6, @7];
    self.paginator.dataPreprocessingBlock = ^NSArray * _Nonnull(id  _Nonnull loadedData, NSError * _Nullable __autoreleasing * _Nullable error) {
        return preprocessingResult;
    };
    OCMStub([self.pagingProviderMock canLoadPageInDirection:AFPageLoadingDirectionForward]).andReturn(YES);
    OCMStub([self.requestHandlerMock sendRequestWithConfiguration:[OCMArg any]
                                                       completion:([OCMArg invokeBlockWithArgs:loadResult, [NSNull null], nil])]);
    id<AFPaginatorDelegate> delegateMock = OCMProtocolMock(@protocol(AFPaginatorDelegate));
    XCTestExpectation *delegateExpectation = [self expectationWithDescription:@"Delegate method call expectation"];
    OCMReject([delegateMock paginator:[OCMArg any] didFailPageLoadingWithError:[OCMArg any] inDirection:0]).ignoringNonObjectArgs;
    OCMStub([delegateMock paginator:self.paginator
                        didLoadPage:preprocessingResult
                        inDirection:AFPageLoadingDirectionForward])
    .andDo(^(NSInvocation *invocation) {
        [delegateExpectation fulfill];
    });
    self.paginator.delegate = delegateMock;
    
    
    //when
    XCTAssertTrue([self.paginator loadPageInDirection:AFPageLoadingDirectionForward]);
    
    //then
    [self waitForExpectations:@[delegateExpectation] timeout:0.1];
}

- (void)testThatErrorReturnedIfPreprocessingBlockReturnsError {
    //given
    NSArray *loadResult = @[@1, @2, @4];
    NSError *preprocessingError = [NSError errorWithDomain:@"TestErrorDomain" code:1 userInfo:nil];
    self.paginator.dataPreprocessingBlock = ^NSArray * _Nonnull(id  _Nonnull loadedData, NSError * _Nullable __autoreleasing * _Nullable error) {
        *error = preprocessingError;
        return @[];
    };
    OCMStub([self.pagingProviderMock canLoadPageInDirection:AFPageLoadingDirectionForward]).andReturn(YES);
    OCMStub([self.requestHandlerMock sendRequestWithConfiguration:[OCMArg any]
                                                       completion:([OCMArg invokeBlockWithArgs:loadResult, [NSNull null], nil])]);
    id<AFPaginatorDelegate> delegateMock = OCMProtocolMock(@protocol(AFPaginatorDelegate));
    XCTestExpectation *delegateExpectation = [self expectationWithDescription:@"Delegate method call expectation"];
    OCMReject([delegateMock paginator:[OCMArg any] didLoadPage:[OCMArg any] inDirection:0]).ignoringNonObjectArgs;
    OCMStub([delegateMock paginator:self.paginator
        didFailPageLoadingWithError:preprocessingError
                        inDirection:AFPageLoadingDirectionForward])
    .andDo(^(NSInvocation *invocation) {
        [delegateExpectation fulfill];
    });
    self.paginator.delegate = delegateMock;
    
    
    //when
    XCTAssertTrue([self.paginator loadPageInDirection:AFPageLoadingDirectionForward]);
    
    //then
    [self waitForExpectations:@[delegateExpectation] timeout:0.1];
    
}

- (void)testThatDelegateFailMethodCalledOnFailedLoadWithCorrectParams {
    //given
    NSError *loadError = [NSError errorWithDomain:@"TestErrorDomain" code:1 userInfo:nil];
    OCMStub([self.pagingProviderMock canLoadPageInDirection:AFPageLoadingDirectionForward]).andReturn(YES);
    OCMStub([self.requestHandlerMock sendRequestWithConfiguration:[OCMArg any]
                                                       completion:([OCMArg invokeBlockWithArgs:[NSNull null], loadError, nil])]);
    id<AFPaginatorDelegate> delegateMock = OCMProtocolMock(@protocol(AFPaginatorDelegate));
    XCTestExpectation *delegateExpectation = [self expectationWithDescription:@"Delegate method call expectation"];
    OCMReject([delegateMock paginator:[OCMArg any] didLoadPage:[OCMArg any] inDirection:0]).ignoringNonObjectArgs;
    OCMStub([delegateMock paginator:self.paginator
        didFailPageLoadingWithError:loadError
                        inDirection:AFPageLoadingDirectionForward])
    .andDo(^(NSInvocation *invocation) {
        [delegateExpectation fulfill];
    });
    self.paginator.delegate = delegateMock;
    
    
    //when
    XCTAssertTrue([self.paginator loadPageInDirection:AFPageLoadingDirectionForward]);
    
    //then
    [self waitForExpectations:@[delegateExpectation] timeout:0.1];
}

@end
