//
//  AFBasePagingConfigurationProvider.m
//
//  Created by Anton Filimonov on 25.09.16.
//  Copyright © 2016 Anton Filimonov. All rights reserved.
//

#import "AFBasePagingParametersProvider.h"

static const NSUInteger kDefaultPageSize = 20;

@implementation AFBasePagingParametersProvider

- (instancetype)init {
    return [self initWithStartIndex:0];
}

- (instancetype)initWithStartIndex:(NSUInteger)startIndex {
    self = [super init];
    if (self) {
        _hasMore = YES;
        _loadedItemsRange = NSMakeRange(startIndex, 0);
        _pageSize = kDefaultPageSize;
    }
    return self;
}

#pragma mark - AFPagingParametersProvider
- (NSDictionary<NSString *,NSNumber *> *)pagingParametersForLoadingNextPageInDirection:(AFPageLoadingDirection)direction {
    return @{};
}

- (BOOL)canLoadPageInDirection:(AFPageLoadingDirection)direction {
    return direction == AFPageLoadingDirectionForward ? self.hasMore : (self.loadedItemsRange.location > self.numerationStartIndex);
}

- (void)handlePageDataLoaded:(id)pageData
               forParameters:(NSDictionary<NSString *, id> *)pageParameters
                   direction:(AFPageLoadingDirection)direction
           loadedItemsNumber:(NSUInteger)loadedItemsNumber {
    NSRange newRange = self.loadedItemsRange;
    newRange.length += loadedItemsNumber;
    if (direction == AFPageLoadingDirectionBackward) {
        if (self.loadedItemsRange.location >= loadedItemsNumber) {
            newRange.location -= loadedItemsNumber;
        } else {
            newRange.location = 0;
        }
    } else if (loadedItemsNumber < self.pageSize) {
        self.hasMore = NO;
    }
    
    self.loadedItemsRange = newRange;
}

@end
