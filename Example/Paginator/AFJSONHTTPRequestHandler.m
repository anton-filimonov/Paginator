//
//  AFJSONHTTPRequestHandler.m
//
//  Created by Anton Filimonov on 12.09.16.
//  Copyright © 2016 Anton Filimonov. All rights reserved.
//

#import "AFJSONHTTPRequestHandler.h"
#import "AFHTTPRequestConfiguration.h"

static const NSTimeInterval kDefaultRequestTimeout = 30.0;

@interface AFJSONHTTPRequestHandler ()

@property (strong, nonatomic) NSURLSession *URLSession;
@property (strong, nonatomic) NSMutableArray<NSURLSessionDataTask *> *processingDataTasks;

@end

@implementation AFJSONHTTPRequestHandler

- (void)dealloc {
    [self cancelAllRequests];
}

#pragma mark - Custom Accessors 
- (NSURLSession *)URLSession {
    if (!_URLSession) {
        _URLSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _URLSession;
}

- (NSMutableArray<NSURLSessionDataTask *> *)processingDataTasks {
    if (!_processingDataTasks) {
        _processingDataTasks = [NSMutableArray new];
    }
    return _processingDataTasks;
}

#pragma mark - AFDataRequestHandler
- (void)sendRequestWithConfiguration:(AFHTTPRequestConfiguration *)requestConfiguration
                          completion:(void (^)(id _Nullable, NSError * _Nullable))completionHandler {
    if (!completionHandler) return;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self requestURLForConfiguration:requestConfiguration]
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:kDefaultRequestTimeout];
    [requestConfiguration.headers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull value, BOOL * _Nonnull stop) {
        [request setValue:value forHTTPHeaderField:key];
    }];
    
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [self.URLSession dataTaskWithRequest:request
                                                        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                            NSError *parsingError = nil;
                                                            id resultObject = [NSJSONSerialization JSONObjectWithData:data
                                                                                                              options:NSJSONReadingAllowFragments
                                                                                                                error:&parsingError];
                                                            completionHandler(resultObject, parsingError);
                                                            
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                [weakSelf removeCompletedTasks];
                                                            });
                                                        }];
    [self.processingDataTasks addObject:dataTask];
    [dataTask resume];
}

- (void)cancelAllRequests {
    [self.processingDataTasks enumerateObjectsUsingBlock:^(NSURLSessionDataTask * _Nonnull dataTask, NSUInteger idx, BOOL * _Nonnull stop) {
        [dataTask cancel];
    }];
    
    [self.processingDataTasks removeAllObjects];
}

#pragma mark - 
- (NSURL *)requestURLForConfiguration:(AFHTTPRequestConfiguration *)configuration {
    NSURL *requestURL = configuration.baseURL;
    if (configuration.requestPath) {
        requestURL = [NSURL URLWithString:configuration.requestPath relativeToURL:configuration.baseURL];
    }
    NSURLComponents *URLComponents = [[NSURLComponents alloc] initWithURL:requestURL resolvingAgainstBaseURL:YES];
    NSMutableString *query = URLComponents.query ? [URLComponents.query mutableCopy] : [NSMutableString new];
    if (query.length > 0) {
        [query appendString:@"&"];
    }
    
    [configuration.parameters enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull value, BOOL * _Nonnull stop) {
        [query appendFormat:@"%@=%@&", key, value];
    }];
    URLComponents.query = query;
    
    return URLComponents.URL;
}

- (void)removeCompletedTasks {
    [self.processingDataTasks filterUsingPredicate:[NSPredicate predicateWithFormat:@"state != %@", @(NSURLSessionTaskStateCompleted)]];
}

@end
