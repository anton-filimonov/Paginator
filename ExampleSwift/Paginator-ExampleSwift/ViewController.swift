//
//  ViewController.swift
//  Paginator-ExampleSwift
//
//  Created by Anton Filimonov on 11/11/2017.
//  Copyright © 2017 Anton Filimonov. All rights reserved.
//

import UIKit
import AFPaginator

class ViewController: UIViewController, PaginatorDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let defaultCellId = "DefaultCellID"
    let activityIndicatorCellId = "ActivityIndicatorCellID"
    let cellActivityIndicatorTag = 111
    let activityIndicatorSectionIndex = 1
    
    let pageSize: UInt = 15
    
    var gotError = false
    
    var dataLoader: Paginator!
    var questionTitles: [String] = []

    @IBOutlet weak var tableView: UITableView!
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.addSubview(self.refreshControl)
        self.resetPageLoader()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func refresh() {
        self.resetPageLoader()
        self.gotError = false
        self.dataLoader?.loadPage(direction: .forward)
    }
    
    //MARK: - PaginatorDelegate
    func pageLoaded(by sender: Paginator, pageData loadedPageItems: [Any], direction: PageLoadingDirection) {
        self.handlePageLoadingFinish(items: loadedPageItems as? [String])
    }
    
    func pageLoadingFailed(by sender: Paginator, error: Error, direction: PageLoadingDirection) {
        print("Page loading failed: \(error)")
        self.gotError = true
        let alert = UIAlertController(title: "Error", message: "Could not load next page", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.handlePageLoadingFinish(items: nil)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - UITableView Delegate and DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.dataLoader.canLoad(direction: .forward) && !self.gotError) ? 2 : 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == self.activityIndicatorSectionIndex ? 1 : self.questionTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == self.activityIndicatorSectionIndex {
            return tableView .dequeueReusableCell(withIdentifier: self.activityIndicatorCellId, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.defaultCellId, for: indexPath)
            cell.textLabel?.text = self.questionTitles[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == self.activityIndicatorSectionIndex {
            if let activityIndicator = cell.viewWithTag(self.cellActivityIndicatorTag) as? UIActivityIndicatorView {
                activityIndicator.startAnimating()
            }
            self.dataLoader.loadPage(direction: .forward)
        }
    }
    
    //MARK: - Helpers
    
    func resetPageLoader() {
        self.dataLoader = Paginator(pagingParametersProvider: self.makePagingParametersProvider(),
                                    requestHandler: JSONHTTPRequestHandler())
        self.dataLoader?.requestConfigurationBuilder = { pageParams -> HTTPRequestConfiguration in
            var requestParameters: [String: Any] = ["site": "stackoverflow",
                                                    "intitle": "iOS",
                                                    "sort": "activity",
                                                    "order": "desc",
                                                    "filter": "!)re8-BMX(NCy.s4L7efN"]
            for (key, value) in pageParams {
                requestParameters[key] = value
            }
            
            return HTTPRequestConfiguration(baseUrl: URL(string: "https://api.stackexchange.com/2.2/")!,
                                            requestPath: "search",
                                            parameters: requestParameters)
        }
        
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
        
        self.dataLoader?.delegate = self
    }
    
    func makePagingParametersProvider() -> PagingParametersProvider {
        let pagingProvider = PageNumberAndSizePagingParametersProvider(startIndex: 1)!
        pagingProvider.pageSize = self.pageSize
        pagingProvider.pageNumberParameterKey = "page"
        pagingProvider.pageSizeParameterKey = "pagesize"
        pagingProvider.numerationStartIndex = 1
        
        return pagingProvider
    }
    
    func handlePageLoadingFinish(items: [String]?) {
        if let pagingProvider = self.dataLoader.pagingParametersProvider as? PageNumberAndSizePagingParametersProvider,
           pagingProvider.loadedItemsRange.length == 1 {
            self.questionTitles = []
        }
        
        if let items = items {
            self.questionTitles += items
        }
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
}
