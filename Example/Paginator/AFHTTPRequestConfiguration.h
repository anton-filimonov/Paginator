//
//  AFHTTPRequestConfiguration.h
//
//  Created by Anton Filimonov on 12.09.16.
//  Copyright © 2016 Anton Filimonov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Basic request configuration
 */
@interface AFHTTPRequestConfiguration : NSObject

/**
 Base URL of the request for paged data
 */
@property (strong, nonatomic) NSURL *baseURL;

/**
 Relative path of the request for paged data
 */
@property (copy, nonatomic) NSString *requestPath;

/**
 Request parameters
 */
@property (copy, nonatomic, nullable) NSDictionary<NSString *, NSString *> *parameters;

/**
 Request headers
 */
@property (copy, nonatomic, nullable) NSDictionary<NSString *, NSString *> *headers;

@end
NS_ASSUME_NONNULL_END
