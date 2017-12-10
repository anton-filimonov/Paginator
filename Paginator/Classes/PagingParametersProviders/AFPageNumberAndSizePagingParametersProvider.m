//
//  AFPageNumberAndSizePagingConfigurationProvider.m
//
//  Created by Anton Filimonov on 26.09.16.
//

#import "AFPageNumberAndSizePagingParametersProvider.h"

static NSString *kDefaultPageSizeParameterKey = @"pageSize";
static NSString *kDefaultPageNumberParameterKey = @"pageNumber";

@implementation AFPageNumberAndSizePagingParametersProvider

#pragma mark - Custom Accessors
- (NSString *)pageSizeParameterKey {
    if (_pageSizeParameterKey) {
        return _pageSizeParameterKey;
    } else {
        return kDefaultPageSizeParameterKey;
    }
}

- (NSString *)pageNumberParameterKey {
    if (_pageNumberParameterKey) {
        return _pageNumberParameterKey;
    } else {
        return kDefaultPageNumberParameterKey;
    }
}

#pragma mark - AFPagingParametersProvider
- (NSDictionary<NSString *,NSNumber *> *)pagingParametersForLoadingNextPageInDirection:(AFPageLoadingDirection)direction {
    if (![self canLoadPageInDirection:direction]) return nil;

    NSUInteger pageNumber = 0;
    if (direction == AFPageLoadingDirectionForward) {
        pageNumber = self.loadedItemsRange.location + self.loadedItemsRange.length;
    } else if (self.loadedItemsRange.location > 0) {
        pageNumber = self.loadedItemsRange.location - 1;
    }
    
    return @{
             self.pageNumberParameterKey: @(pageNumber),
             self.pageSizeParameterKey: @(self.pageSize)
             };
}

- (void)handlePageDataLoaded:(id)pageData
               forParameters:(NSDictionary<NSString *, id> *)pageParameters
                   direction:(AFPageLoadingDirection)direction
           loadedItemsNumber:(NSUInteger)loadedItemsNumber {
    NSRange newRange = self.loadedItemsRange;
    newRange.length ++;
    if (direction == AFPageLoadingDirectionBackward && newRange.location > 0) {
        newRange.location--;
    } else if (loadedItemsNumber < self.pageSize) {
        self.hasMore = NO;
    }
    
    self.loadedItemsRange = newRange;
}

@end
