//
//  AFPaginator.h
//
//  Created by Anton Filimonov on 05.09.16.
//  Copyright © 2016 Anton Filimonov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFPageLoadingDirection.h"
#import "AFPaginatorDelegate.h"
#import "AFPagingParametersProvider.h"
#import "AFDataRequestHandler.h"

NS_ASSUME_NONNULL_BEGIN

/**
 This class encapsulates all the operations you typically implement for page-based data loading.
 */
NS_SWIFT_NAME(Paginator)
@interface AFPaginator : NSObject

/**
 The object, that will be informed of the load state changes. It's methods will be called in main thread
 */
@property (weak, nonatomic, nullable) id<AFPaginatorDelegate> delegate;

/**
 The object, that defines server specific behaviour of the loader. It provides paginator
 instance with the configuration for requests to the server. It's methods will be called in the same thread,
 the request handler calls it's callback methods in
 */
@property (strong, nonatomic, readonly) id<AFPagingParametersProvider> pagingParametersProvider;

/**
 The block is used to create request configuration from parameters returned by \c pagingConfigurationProvider
 which will then be sent as a first parameter to \c sendRequestWithConfiguration:completion: method of \c pagingConfigurationProvider.
 If \c nil, the original \c NSDictionary received from \c pagingConfigurationProvider will be used as a request configuration
 */
@property (copy, nonatomic, nullable) id(^requestConfigurationBuilder)(NSDictionary<NSString *, id> *);

/**
 The object, that is supposed to perform the request according to the configuration returned by \c pagingConfigurationProvider
 */
@property (strong, nonatomic, readonly) id<AFDataRequestHandler> requestHandler;

/**
 You can use this property to keep some data, related to data beeing loaded
 */
@property (copy, nonatomic, nullable) NSDictionary *userInfo;

/**
 This block could be used for data preprocessing in case when, for example, loaded data is not an array,
 but it contains needed array or if you want to map received data into your custom data model objects.
 Its' first parameter is data as it's been received from \c requestHandler and second parameter allows
 you to return an error object if data is incorrect. If This block returns nil, data is beeing processed
 as incorrect.
 This block is called in thread request handler calls it's callback methods in.
 */
@property (copy, nonatomic, nullable) NSArray * _Nullable (^dataPreprocessingBlock)(id loadedData, NSError **error);

/**
 Initializes the new object
 
 @param pagingParametersProvider The object, that defines server specific behaviour of the loader.
 It provides returned instance with the configurations for requests to the server
 
 @param requestHandler The object, that is supposed to perform the request according to the configuration
 returned by \c pagingConfigurationProvider
 */
- (instancetype)initWithPagingParametersProvider:(id<AFPagingParametersProvider>)pagingParametersProvider
                                  requestHandler:(id<AFDataRequestHandler>)requestHandler;

/**
 Shows whether it's possible to load previous/next page or not, according to paging configuration provider

 @param direction the direction, you want to check possibility to load data in
 */
- (BOOL)canLoadInDirection:(AFPageLoadingDirection)direction NS_SWIFT_NAME(canLoad(direction:));

/**
 Shows if the object is loading previous/next page right now

 @param direction the direction to check if data loading is in progress in
 */
- (BOOL)isLoadingInProgressInDirection:(AFPageLoadingDirection)direction NS_SWIFT_NAME(isLoadingInProgress(direction:));

/**
 Starts loading new page in selected direction if possible (it could be impossible if loading is
 in progress in selected direction or if \c pagingConfigurationProvider tells that there's nothing
 to load any more in this direction)

 @param direction direction to load one more page
 @return \c YES if page loading has been started, otherwise - \c NO (if it's impossible for current moment and selected direction)
 */
- (BOOL)loadPageInDirection:(AFPageLoadingDirection)direction NS_SWIFT_NAME(loadPage(direction:));

@end

NS_ASSUME_NONNULL_END
