//
//  AFDataRequestHandler.h
//  Paginator
//
//  Created by Anton Filimonov on 28/09/2017.
//

#ifndef AFDataRequestHandler_h
#define AFDataRequestHandler_h

NS_ASSUME_NONNULL_BEGIN
NS_SWIFT_NAME(DataRequestHandler)
@protocol AFDataRequestHandler
@required

/**
 *  Starts loading of a new page of data, using request configuration to generate the request.
 *  (the object should be able to process more than one request simultaneously)
 *
 *  @param requestConfiguration the object containing data needed to create and send the request
 *
 *  @param completionHandler the block, that will be called after request finish, which takes the data,
 *  returned by data source as first parameter and the received error as a second parameter (each of them could
 *  be nil depending on the request result)
 */
- (void)sendRequestWithConfiguration:(id)requestConfiguration
                          completion:(void(^)(id _Nullable resultData, NSError * _Nullable error))completionHandler NS_SWIFT_NAME(sendRequest(configuration:completion:));

/**
 *  Cancells all the pending requests
 */
- (void)cancelAllRequests;

@end

NS_ASSUME_NONNULL_END

#endif /* AFDataRequestHandler_h */
