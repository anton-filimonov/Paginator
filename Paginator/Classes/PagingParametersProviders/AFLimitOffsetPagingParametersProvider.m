//
//  AFLimitOffsetPagingConfigurationProvider.m
//
//  Created by Anton Filimonov on 26.09.16.
//  Copyright © 2016 Anton Filimonov. All rights reserved.
//

#import "AFLimitOffsetPagingParametersProvider.h"

static NSString *kDefaultLimitParameterKey = @"limit";
static NSString *kDefaultOffsetParameterKey = @"offset";

@implementation AFLimitOffsetPagingParametersProvider

#pragma mark - Custom Accessors
- (NSString *)limitParameterKey {
    if (_limitParameterKey) {
        return _limitParameterKey;
    } else {
        return kDefaultLimitParameterKey;
    }
}

- (NSString *)offsetParameterKey {
    if (_offsetParameterKey) {
        return _offsetParameterKey;
    } else {
        return kDefaultOffsetParameterKey;
    }
}

#pragma mark - AFPagingParametersProvider
- (NSDictionary<NSString *,NSNumber *> *)pagingParametersForLoadingNextPageInDirection:(AFPageLoadingDirection)direction {
    if (![self canLoadPageInDirection:direction]) return nil;

    NSUInteger offset = 0;
    NSUInteger limit = self.pageSize;
    if (direction == AFPageLoadingDirectionForward) {
        offset = self.loadedItemsRange.location + self.loadedItemsRange.length;
    } else if (self.loadedItemsRange.location > self.numerationStartIndex) {
        if (self.loadedItemsRange.location >= self.numerationStartIndex + self.pageSize) {
            offset = self.loadedItemsRange.location - self.pageSize;
        } else {
            offset = self.numerationStartIndex;
            limit = self.loadedItemsRange.location - self.numerationStartIndex;
        }
    }
    
    return @{
             self.offsetParameterKey: @(offset),
             self.limitParameterKey: @(limit)
             };
}

@end
