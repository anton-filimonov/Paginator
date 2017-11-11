//
//  AFPagingParametersProvider.h
//  Paginator
//
//  Created by Anton Filimonov on 28/09/2017.
//

#ifndef AFPagingParametersProvider_h
#define AFPagingParametersProvider_h
#import "AFPageLoadingDirection.h"

NS_ASSUME_NONNULL_BEGIN
NS_SWIFT_NAME(PagingParametersProvider)
@protocol AFPagingParametersProvider <NSObject>
@required

/**
 This method is called when the data loader wants to know if it's possible to load one more page in the selected direction

 @param direction selected direction
 @return \c YES if it's possible to load at least one more page in selected direction and \c NO otherwise (for example if \c direction is backward and the very first page is already loaded)
 */
- (BOOL)canLoadPageInDirection:(AFPageLoadingDirection)direction NS_SWIFT_NAME(canLoadPage(direction:));

/**
 Creates configuration for the request to load page in selected direction (the returned object must be of the type that is
 supported by \c requestHandler of the \c AFPaginator used with this configuration provider). If \c canLoadPageInDirection:
 for \c direction returns NO, this method should return \c nil
 
 @param direction selected direction
 */
- (NSDictionary<NSString *, id> *)pagingParametersForLoadingNextPageInDirection:(AFPageLoadingDirection)direction NS_SWIFT_NAME(pagingParametersForNextPage(direction:));

@optional

/**
 This method is called when new page of data is loaded. It should be used for updating configuration providers'
 data needed to create request configurations
 @attention This method is called in the thread in wich request handler calls completion handler but always before the paginator delegate success method
 
 @param pageData the data as it has been loaded by the request handler (without preprocessing with the provided block).
 this data could be usefull if the returned data contains not only an array of needed items but also some specific information
 needed to configure the request for another page
 
 @param pageParameters the request parameters used to load this data.
 
 @param direction direction for the loaded page (is this next or previous page)
 
 @param loadedItemsNumber number of items loaded (number of items in array returned from request handler or by preprocessing block, if provided)
 */
- (void)handlePageDataLoaded:(id)pageData
               forParameters:(NSDictionary<NSString *, id> *)pageParameters
                   direction:(AFPageLoadingDirection)direction
           loadedItemsNumber:(NSUInteger)loadedItemsNumber;

@end

NS_ASSUME_NONNULL_END

#endif /* AFPagingParametersProvider_h */
