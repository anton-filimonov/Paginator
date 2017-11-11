//
//  AFViewController.m
//  Paginator
//
//  Created by Anton Filimonov on 09/28/2017.
//  Copyright (c) 2017 Anton Filimonov. All rights reserved.
//

@import Paginator;

#import "AFViewController.h"
#import "AFJSONHTTPRequestHandler.h"
#import "AFHTTPRequestConfiguration.h"

static NSString * const kDefaultCellID = @"DefaultCellID";
static NSString * const kActivityIndicatorCellID = @"ActivityIndicatorCellID";
static const NSInteger kCellActivityIndicatorTag = 111;

static const NSInteger kLoadingPageSize = 15;

NS_ENUM(NSInteger, QuestionsTableSection) {
    QuestionsTableSectionData = 0,
    QuestionsTableSectionActivityIndicator
};

@interface AFViewController () <AFPaginatorDelegate>

@property (strong, nonatomic) AFPaginator *dataLoader;
@property (strong, nonatomic) NSMutableArray<NSString *> * questionTitles;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation AFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupUI];
    [self resetPageLoader];
}

- (void)setupUI {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)resetPageLoader {
    self.dataLoader = [[AFPaginator alloc] initWithPagingParametersProvider:[self createPagingProvider]
                                                             requestHandler:[AFJSONHTTPRequestHandler new]];
    
    //create request configuration that could be handled by our request handler according to page parameters provided
    self.dataLoader.requestConfigurationBuilder = ^id _Nonnull(NSDictionary<NSString *,id> *pageParams) {
        NSMutableDictionary *requestParameters = [@{@"site" : @"stackoverflow",
                                                    @"intitle" : @"iOS",
                                                    @"sort" : @"activity",
                                                    @"order" : @"desc",
                                                    @"filter" : @"!)re8-BMX(NCy.s4L7efN"} mutableCopy];
        [requestParameters addEntriesFromDictionary:pageParams];
        
        AFHTTPRequestConfiguration * result = [AFHTTPRequestConfiguration new];
        result.baseURL = [NSURL URLWithString:@"https://api.stackexchange.com/2.2/"];
        result.requestPath = @"search";
        result.parameters = requestParameters;
        
        return result;
    };
    
    // if your backend returns array of objects which you're ok to use, you're not gonna need this block
    // but if we receive them wrapped in some other objects, this block is a good place to perform unwrapping
    self.dataLoader.dataPreprocessingBlock = ^NSArray *(id loadedData, NSError **error) {
        if (error != NULL) {
            *error = nil;
        }
        @try {
            //we are going to show only question titles, so let's get titles from received dictionary.
            return [loadedData valueForKeyPath:@"items.title"];
        } @catch (NSException *exception) {
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"Domain" code:1000 userInfo:nil];
            }
            return nil;
        }
    };
    
    self.dataLoader.delegate = self;
}

- (AFPageNumberAndSizePagingParametersProvider *)createPagingProvider {
    AFPageNumberAndSizePagingParametersProvider *pagingProvider = [[AFPageNumberAndSizePagingParametersProvider alloc] initWithStartIndex:1];
    pagingProvider.pageSize = kLoadingPageSize;
    pagingProvider.pageNumberParameterKey = @"page";
    pagingProvider.pageSizeParameterKey = @"pagesize";
    pagingProvider.numerationStartIndex = 1;
    
    return pagingProvider;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (void)refresh:(UIRefreshControl *)refreshControl {
    [self resetPageLoader];
    [self.dataLoader loadPageInDirection:AFPageLoadingDirectionForward];
}

#pragma mark - UITableView Delegate and DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataLoader canLoadInDirection:AFPageLoadingDirectionForward] ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == QuestionsTableSectionData) ? self.questionTitles.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == QuestionsTableSectionData) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCellID forIndexPath:indexPath];
        cell.textLabel.text = self.questionTitles[indexPath.row];
        return cell;
    } else {
        return [tableView dequeueReusableCellWithIdentifier:kActivityIndicatorCellID forIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == QuestionsTableSectionActivityIndicator) {
        UIActivityIndicatorView *activityIndicator = [cell.contentView viewWithTag:kCellActivityIndicatorTag];
        [activityIndicator startAnimating];
        [self.dataLoader loadPageInDirection:AFPageLoadingDirectionForward]; //no need to check if loading is currently in progress, cause loader does this check itself
    }
}

#pragma mark - AFPagedDataLoaderDelegate
- (void)paginator:(AFPaginator *)sender didLoadPage:(NSArray *)loadedPageItems inDirection:(AFPageLoadingDirection)direction {
    [self handlePageLoadingFinishWithItems:loadedPageItems];
}

- (void)paginator:(AFPaginator *)sender didFailPageLoadingWithError:(NSError *)error inDirection:(AFPageLoadingDirection)direction {
    NSLog(@"%@: error: %@", NSStringFromSelector(_cmd), error);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:@"Could not load next page"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    [self handlePageLoadingFinishWithItems:nil];
}

- (void)handlePageLoadingFinishWithItems:(NSArray<NSString *> *)items {
    if ([(AFPageNumberAndSizePagingParametersProvider *)self.dataLoader.pagingParametersProvider loadedItemsRange].length == 1) {
        //we've just reloaded data
        self.questionTitles = [NSMutableArray new];
    }
    
    if (items) {
        [self.questionTitles addObjectsFromArray:items];
    }
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

@end
