//
//  AFPaginator.m
//
//  Created by Anton Filimonov on 05.09.16.
//  Copyright © 2016 Anton Filimonov. All rights reserved.
//

#import "AFPaginator.h"

@interface AFPaginator ()

@property (assign, atomic) BOOL nowLoadingForward;
@property (assign, atomic) BOOL nowLoadingBackward;

@end

@implementation AFPaginator

- (instancetype)initWithPagingParametersProvider:(id<AFPagingParametersProvider>)pagingParametersProvider
                                  requestHandler:(id<AFDataRequestHandler>)requestHandler {
    self = [super init];
    if (self) {
        _pagingParametersProvider = pagingParametersProvider;
        _requestHandler = requestHandler;
    }
    return self;
}

- (void)dealloc {
    [self.requestHandler cancelAllRequests];
}

#pragma mark - Public State
- (BOOL)canLoadInDirection:(AFPageLoadingDirection)direction {
    return [self.pagingParametersProvider canLoadPageInDirection:direction];
}

- (BOOL)isLoadingInProgressInDirection:(AFPageLoadingDirection)direction {
    return direction == AFPageLoadingDirectionForward ? self.nowLoadingForward : self.nowLoadingBackward;
}

#pragma mark -
- (BOOL)loadPageInDirection:(AFPageLoadingDirection)direction {
    if ([self isLoadingInProgressInDirection:direction] ||
        ![self.pagingParametersProvider canLoadPageInDirection:direction]) {
            return NO;
    }
    
    [self setIsNowLoading:YES inDirection:direction];
    
    NSDictionary *pageParameters = [self.pagingParametersProvider pagingParametersForLoadingNextPageInDirection:direction];
    
    id requestConfiguration = pageParameters;
    if (self.requestConfigurationBuilder != nil) {
        requestConfiguration = self.requestConfigurationBuilder(pageParameters);
    }
    
    __weak typeof(self) bself = self;
    [self.requestHandler sendRequestWithConfiguration:requestConfiguration
                                           completion:^(id  _Nullable resultData, NSError * _Nullable error) {
                                               [bself setIsNowLoading:NO inDirection:direction];
                                               if (error) {
                                                   [bself handleLoadingError:error inDirection:direction];
                                               } else {
                                                   [bself handleLoadedData:resultData
                                                             forParameters:pageParameters
                                                               inDirection:direction];
                                               }
                                           }];
    return YES;
}

#pragma mark - Internal
- (void)setIsNowLoading:(BOOL)isLoading inDirection:(AFPageLoadingDirection)direction {
    if (direction == AFPageLoadingDirectionForward) {
        self.nowLoadingForward = isLoading;
    } else {
        self.nowLoadingBackward = isLoading;
    }
}

- (void)handleLoadingError:(NSError *)loadingError inDirection:(AFPageLoadingDirection)direction {
    if ([self.delegate respondsToSelector:@selector(paginator:didFailPageLoadingWithError:inDirection:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate paginator:self didFailPageLoadingWithError:loadingError inDirection:direction];
        });
    }
}

- (void)handleLoadedData:(id)data
           forParameters:(NSDictionary<NSString *, id> *)pageParameters
             inDirection:(AFPageLoadingDirection)direction {
    NSArray *result = data;
    if (self.dataPreprocessingBlock) {
        NSError *dataPreprocessingError = nil;
        result = self.dataPreprocessingBlock(data, &dataPreprocessingError);
        if (dataPreprocessingError) {
            [self handleLoadingError:dataPreprocessingError inDirection:direction];
            return;
        }
    }
    
    if ([self.pagingParametersProvider respondsToSelector:@selector(handlePageDataLoaded:forParameters:direction:loadedItemsNumber:)]) {
        [self.pagingParametersProvider handlePageDataLoaded:data
                                                 forParameters:pageParameters
                                                     direction:direction
                                             loadedItemsNumber:result.count];
    }
    
    if ([self.delegate respondsToSelector:@selector(paginator:didLoadPage:inDirection:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate paginator:self didLoadPage:result inDirection:direction];
        });
    }
}

@end
