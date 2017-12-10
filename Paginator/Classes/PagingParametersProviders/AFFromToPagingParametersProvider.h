//
//  AFFromToPagingConfigurationProvider.h
//
//  Created by Anton Filimonov on 12.09.16.
//

#import <Foundation/Foundation.h>
#import "AFBasePagingParametersProvider.h"

/**
 The configuration provider, that works with servers, where page limits are set with \c from and \c to parameters
 */
@interface AFFromToPagingParametersProvider : AFBasePagingParametersProvider

/**
 The key in the parameters dictionary for the \c from value. Default value is \c @"from"
 */
@property (copy, nonatomic, nonnull) NSString *fromParameterKey;

/**
 The key in the parameters dictionary for the \c to value. Default value is \c @"to"
 */
@property (copy, nonatomic, nonnull) NSString *toParameterKey;

@end
