//
//  AFFromToPagingConfigurationProvider.m
//
//  Created by Anton Filimonov on 12.09.16.
//

#import "AFFromToPagingParametersProvider.h"

static NSString *kDefaultFromParameterKey = @"from";
static NSString *kDefaultToParameterKey = @"to";

@implementation AFFromToPagingParametersProvider

#pragma mark - Custom Accessors
- (NSString *)fromParameterKey {
    if (_fromParameterKey) {
        return _fromParameterKey;
    } else {
        return kDefaultFromParameterKey;
    }
}

- (NSString *)toParameterKey {
    if (_toParameterKey) {
        return _toParameterKey;
    } else {
        return kDefaultToParameterKey;
    }
}

#pragma mark - AFPagingParametersProvider
- (NSDictionary<NSString *,NSNumber *> *)pagingParametersForLoadingNextPageInDirection:(AFPageLoadingDirection)direction {
    if (![self canLoadPageInDirection:direction]) return nil;

    NSUInteger fromIndex = 0;
    NSUInteger toIndex = 0;
    if (direction == AFPageLoadingDirectionForward) {
        fromIndex = self.loadedItemsRange.location + self.loadedItemsRange.length;
        toIndex = fromIndex + self.pageSize - 1;
    } else if (self.loadedItemsRange.location > self.numerationStartIndex) {
        if (self.loadedItemsRange.location >= self.numerationStartIndex + self.pageSize) {
            fromIndex = self.loadedItemsRange.location - self.pageSize;
        } else {
            fromIndex = self.numerationStartIndex;
        }
        toIndex = self.loadedItemsRange.location - 1;
    }
    
    return @{
             self.fromParameterKey: @(fromIndex),
             self.toParameterKey: @(toIndex)
             };
}

@end
