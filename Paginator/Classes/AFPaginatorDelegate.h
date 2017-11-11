//
//  AFPagedDataLoaderDelegate.h
//  Paginator
//
//  Created by Anton Filimonov on 28/09/2017.
//

#ifndef AFPagedDataLoaderDelegate_h
#define AFPagedDataLoaderDelegate_h

NS_ASSUME_NONNULL_BEGIN

@class AFPaginator;

NS_SWIFT_NAME(PaginatorDelegate)
@protocol AFPaginatorDelegate <NSObject>
@optional

/**
 *  This method is called when the data loader has successfully loaded a page of data
 *
 *  @param sender the object that loaded the data
 *
 *  @param loadedPageItems the data from loaded page
 *
 *  @param direction shows where the received data is going to be inserted in result array
 */
- (void)paginator:(AFPaginator *)sender didLoadPage:(NSArray *)loadedPageItems inDirection:(AFPageLoadingDirection)direction NS_SWIFT_NAME(pageLoaded(by:pageData:direction:));

/**
 *  This method is called when the data loader failed loading of the page
 *
 *  @param sender the object that tried to load data
 *
 *  @param error description of the received error
 *
 *  @param direction shows where the received data is going to be inserted in result array
 */
- (void)paginator:(AFPaginator *)sender didFailPageLoadingWithError:(NSError *)error inDirection:(AFPageLoadingDirection)direction NS_SWIFT_NAME(pageLoadingFailed(by:error:direction:));

@end

NS_ASSUME_NONNULL_END

#endif /* AFPagedDataLoaderDelegate_h */
