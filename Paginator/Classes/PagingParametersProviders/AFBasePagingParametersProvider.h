//
//  AFBasePagingConfigurationProvider.h
//
//  Created by Anton Filimonov on 25.09.16.
//

#import <Foundation/Foundation.h>
#import "AFPagingParametersProvider.h"

/**
 It is the abstract class that could be used as a base class for your paging configuration providers.
 In it's implementation of the pagedDataLoader:didLoadPageData:forParameters:loadedItemsNumber:isForward:
 method it adjusts \c loadedItems range according to the number of loaded items and the direction 
 */
@interface AFBasePagingParametersProvider : NSObject <AFPagingParametersProvider>

/**
 Means number of items per page, defaults to 20
 */
@property (assign, nonatomic) NSUInteger pageSize;

/**
 This property is used to store the range of loaded items
 */
@property (assign, nonatomic) NSRange loadedItemsRange;

/**
 This flag is going to be used to mark whether it's possible to load page forward or not. 
 (\c loadedItemsRange supposed to be usefull for getting the same info for previous page)
 */
@property (assign, nonatomic) BOOL hasMore;

/**
 Minimal value of the parameter, which sets the offset of the loading page (pageNumber/offset/from/etc.). Defaults to \c 0
 */
@property (assign, nonatomic) NSUInteger numerationStartIndex;

/**
 Initializes new instance, and sets \c  loadedItemsRange property to the value {\c startIndex, \c 0}

 @param startIndex the index to start loading from (you do not always want to start loading from 
 the very beginning and also some servers start counting from 0 and some other ones start from 1)
 */
- (instancetype)initWithStartIndex:(NSUInteger)startIndex NS_DESIGNATED_INITIALIZER NS_SWIFT_NAME(init(startIndex:));

/**
 Creates new paging parameters dictionary. Since all the related params in presented providers are
 numbers, values in the result are constrained to NSNumber type. Default implementation returns an empty dictionary.
 
 For all the rest of information about this method take a look at documentation 
 for \n AFPagingParametersProvider Protocol
 */
- (NSDictionary<NSString *, NSNumber *> *)pagingParametersForLoadingNextPageInDirection:(AFPageLoadingDirection)direction NS_SWIFT_NAME(pagingParametersForNextPage(direction:));

@end
