# Paginator

[![Version](https://img.shields.io/cocoapods/v/AFPaginator.svg?style=flat)](http://cocoapods.org/pods/AFPaginator)
[![License](https://img.shields.io/cocoapods/l/AFPaginator.svg?style=flat)](http://cocoapods.org/pods/AFPaginator)
[![Platform](https://img.shields.io/cocoapods/p/AFPaginator.svg?style=flat)](http://cocoapods.org/pods/AFPaginator)

It is a small library that simplifies your work with services allowing you to load data in chunks defined by some parameters. It takes the most common responsibilities of paged data loading: preventing many requests for the same page, keeping track of loaded data range, providing next/previous page parameters.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first. The same way you can run the swift example project in ExampleSwift directory.

## Requirements
It should work properly with older versions but has been tested on iOS 8.4 and higher in Xcode 9.1.

## Features
 * Swift ready (all classes and method names adopted to Swift)
 * 100% tested
 * High flexibility. Customize the process, providing your own implementations of all the dependencies
 * Fully documented
 * CocoaPods installable

## Installation

### CocoaPods

Paginator is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Paginator'
```

This installation will give only the core class with all the needed protocols.
If you also want to use one of the provided paging parameter providers (or all of them), you will need to add

 ```ruby
 pod 'Paginator/ParametersProviders'
```

Then run `pod install`.

### Manually

You also can just copy all the files from the Classes directory (Whether to include files from its' subdirectory PagingParametersProviders depends on your needs)

## Main Idea

Very often we have to download data divided into chunks. Sometimes we also need to be able to handle downloading not only forward (for example we can start loading not from the very beginning) Doing that we mostly have to solve the same problems: prevent loading the same page more than once, prevent races in page loading, holding load state and generating parameters for next/previous page. Paginator is going to solve most of them.

Its main components are:

* `Paginator` itself - the main entry point. Connecting all other parts together. Holds loading state (whether download is in progress for any direction or not)
* `Paging Parameters Provider` - part of paginators' state which moved to separate class to provide more flexibility. It provider parameters for next page in selected direction. The parameters depend on the server you have to deal with. The most basically used parameters providers (for servers, using from-to, limit-offset or pageNumber-pageSize coordinate systems for data chunks) could be installed as `Paginator/ParametersProviders` pod or from `Classes/PagingParametersProviders` directory if you prefer to install manually.
* `Request Configuration Builder` we use different frameworks and libraries to perform network requests but all of them use some configuration to describe the request (`NSURLRequest` for example). PagingParametersProvider gives only a dictionary with parameters for needed page, but you also could need to add some other parameters, headers and you can use whatever classes to describe the request. And Request Configuration Builder is the right place to put your request decription constructor.
* `Data Preprocessing Block` - this block will be used to process the received data before returning it to the delegate. It's going to be usefull if your server returns needed data wrapped into some dictionary or if you want to receive the result mapped into your internal data classes or if you need to perform any data transformations to receive the array of data, you need
* `Request Handler` - performs request (usually network request, but actually that depends only on your handler). The library does not provide this component but only a protocol defining requirements to it, because concrete implementation could highly depend on app architecture and needs.

So when you ask paginator to download next page, it
1. Asks parameters for the page from Paging Parameters Provider
2. Creates request configuration using Request Configuration Builder (or uses parameters returned by Paging Parameters Provider if builder is not set)
3. Asks Request Handler to perform the request
4. After receiving the data, process it through Data Preprocessing Block (if it's set)
5. Tells Paging Parameters Provider that page is loaded to let it update it's internal state to get ready for next loads
6. Provide its' delegate with loaded data

## Usage

To use paginator you first need to configure it like this (this looks pretty long but it really depends on the server you work with):
```Objective-C
// Create paging provider
AFPageNumberAndSizePagingParametersProvider *pagingProvider = [[AFPageNumberAndSizePagingParametersProvider alloc] initWithStartIndex:1];
pagingProvider.pageSize = 20;
pagingProvider.pageNumberParameterKey = @"page";
pagingProvider.pageSizeParameterKey = @"pagesize";
pagingProvider.numerationStartIndex = 1;

// Create the paginator itself
AFPaginator *dataLoader = [[AFPaginator alloc] initWithPagingParametersProvider:pagingProvider requestHandler:/*your custom handler*/];

// set configuration builder if needed
self.dataLoader.requestConfigurationBuilder = ^id _Nonnull(NSDictionary<NSString *,id> *pageParams) {
AFHTTPRequestConfiguration * result = [AFHTTPRequestConfiguration new];
  result.baseURL = [NSURL URLWithString:@"URL string"];
  result.requestPath = @"search";
  result.parameters = pageParams;

  return result;
};

// set preprocessing block if needed
dataLoader.dataPreprocessingBlock = ^NSArray *(id loadedData, NSError **error) {
  if (error != NULL) {
    *error = nil;
  }
  @try {
    return [loadedData valueForKeyPath:@"items.title"];
  } @catch (NSException *exception) {
    if (error != NULL) {
      *error = [NSError errorWithDomain:@"Domain" code:1000 userInfo:nil];
    }
    return nil;
  }
};

// set delegate
self.dataLoader.delegate = self;

//then just save paginator object somewhere
```

or the same in Swift
```Swift
// Create paging provider
let pagingProvider = PageNumberAndSizePagingParametersProvider(startIndex: 1)!
pagingProvider.pageSize = self.pageSize
pagingProvider.pageNumberParameterKey = "page"
pagingProvider.pageSizeParameterKey = "pagesize"
pagingProvider.numerationStartIndex = 1

// Create the paginator itself
let dataLoader = Paginator(pagingParametersProvider: pagingProvider, requestHandler: /*your custom handler*/)

// set configuration builder if needed
dataLoader.requestConfigurationBuilder = { pageParams -> HTTPRequestConfiguration in
  return HTTPRequestConfiguration(baseUrl: URL(string: "URL string")!,
  requestPath: "search",
  parameters: pageParams)
}

// set preprocessing block if needed
self.dataLoader?.dataPreprocessingBlock = {
  (sourceData, error) -> [Any]? in
  error?.pointee = nil

  guard let data = sourceData as? [String: Any],
    let items = data["items"] as? [[String: Any]]
    else {
      error?.pointee = NSError(domain: "Paging error", code: 1000, userInfo: nil)
      return nil
    }

  return items.flatMap { $0["title"] as? String }
}

// set delegate
dataLoader.delegate = self

//then just save paginator object somewhere
```

Then just implement needed methods in your delegate and call `loadPageInDirection:` to start loading.

For full example of how to use it, see Example.

## Author

[Anton Filimonov](https://github.com/anton-filimonov)

## License

Paginator is available under the MIT license. See the LICENSE file for more info.
