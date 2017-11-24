//
//  AFJSONHTTPRequestHandler.h
//
//  Created by Anton Filimonov on 12.09.16.
//  Copyright © 2016 Anton Filimonov. All rights reserved.
//

@import AFPaginator;

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AFHTTPRequestConfiguration;

/**
 Basic request handler. Uses instances of class \c AFHTTPRequestConfiguration as request configurations. 
 Uses NSURLSession for performing requests
 */
@interface AFJSONHTTPRequestHandler : NSObject <AFDataRequestHandler>

- (void)sendRequestWithConfiguration:(AFHTTPRequestConfiguration *)requestConfiguration completion:(void (^)(id _Nullable, NSError * _Nullable))completionHandler;

@end

NS_ASSUME_NONNULL_END
