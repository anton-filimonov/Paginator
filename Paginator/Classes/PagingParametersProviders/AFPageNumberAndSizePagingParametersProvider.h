//
//  AFPageNumberAndSizePagingConfigurationProvider.h
//
//  Created by Anton Filimonov on 26.09.16.
//

#import "AFBasePagingParametersProvider.h"

/**
 The configuration provider, that works with servers, where page limits are set with number 
 of items per page and number of needed page
 */
NS_SWIFT_NAME(PageNumberAndSizePagingParametersProvider)
@interface AFPageNumberAndSizePagingParametersProvider : AFBasePagingParametersProvider

/**
 The key in the parameters dictionary for the page size value. Default value is \c @"pageSize"
 */
@property (copy, nonatomic, nonnull) NSString *pageSizeParameterKey;

/**
 The key in the parameters dictionary for the page number value. Default value is \c @"pageNumber"
 */
@property (copy, nonatomic, nonnull) NSString *pageNumberParameterKey;

@end
