//
//  AFLimitOffsetPagingConfigurationProvider.h
//
//  Created by Anton Filimonov on 26.09.16.
//

#import "AFBasePagingParametersProvider.h"

/**
 The configuration provider, that works with servers, where page limits are set with \c offset and \c limit parameters
 */
@interface AFLimitOffsetPagingParametersProvider : AFBasePagingParametersProvider

/**
 The key in the parameters dictionary for the limit value. Default value is \c @"limit"
 */
@property (copy, nonatomic, nonnull) NSString *limitParameterKey;

/**
 The key in the parameters dictionary for the offset value. Default value is \c @"offset"
 */
@property (copy, nonatomic, nonnull) NSString *offsetParameterKey;

@end
