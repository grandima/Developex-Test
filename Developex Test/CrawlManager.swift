//
//  CrawlManager.swift
//  Developex Test
//
//  Created by Dima Medynsky on 4/21/16.
//  Copyright © 2016 Dima Medynsky. All rights reserved.
//

import Foundation
import Alamofire
//enum URLCrawlState {
//    case Downloading, Found(Int), NotFound, Error
//}

public class CrawlManager {
    
    private var barrierQueue = dispatch_queue_create("grandima.Developex-Test.CrawlManager", DISPATCH_QUEUE_CONCURRENT)
    private var pendingURLs = SynchronizedQueue<Occurrence>()
    private var results = [Occurrence]()
    
    private var stopped: Bool = false
    private var suspended: Bool = false
    
    private var notFinishedResults: Bool {
        var result = false
        dispatch_sync(barrierQueue) {
            result = self.results.notFinished
        }
        return result
    }
    
    private var resultsCount: Int {
        var count = 0
        dispatch_sync(barrierQueue) {
            count = self.results.count
        }
        return count
    }
    
    public func addURL(url: String) {
        dispatch_barrier_sync(barrierQueue) {
            if self.results.count < Settings.maxURLNumber {
                var occured = false
                for item in self.results {
                    if item.url == url {
                        occured = true
                        break
                    }
                }
                if !occured {
                    let occurance = Occurrence(url: url)
                    self.pendingURLs.push(occurance)
                    self.results.append(occurance)
                }
            }
        }
    }
    
    public static let sharedManager = CrawlManager()
    
    lazy var session: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var queue = NSOperationQueue()
        queue.name = "Crawl Queue"
        queue.maxConcurrentOperationCount = Settings.maxURLNumber
        let session = NSURLSession(configuration: configuration, delegate: nil, delegateQueue: queue)
        return session
    }()
    
    func start(url: String) {
        addURL(url)
        
        while !stopped && !suspended && notFinishedResults && resultsCount <= Settings.maxURLNumber {
            
            guard let occurance = pendingURLs.pop() else { continue }
            guard let url = NSURL(string: occurance.url) else { continue }
            
            session.dataTaskWithURL(url, completionHandler: { [unowned occurance](data, response, error) in
                if let data = data where error == nil {
                    
                    guard let text = String(data: data, encoding: NSUTF8StringEncoding) else {
                        occurance.crawlStatus = .Error
                        return
                    }
                    
                    let links = text.links
                    links.forEach{ self.addURL($0) }
                    
                    let occurenceCount = text.occurences(Settings.textToFind)
                    if occurenceCount > 0 {
                        occurance.count = occurenceCount
                        occurance.crawlStatus = .Finished
                    } else {
                        occurance.crawlStatus = .NotFound
                    }
                } else {
                    occurance.crawlStatus = .Error
                }
                }).resume()
        }
    }
    
    
    //    private func setCount(item: Occurrence, count: Int) {
    //        dispatch_barrier_sync(barrierQueue) {
    //            item.count = count
    //            item.crawlStatus = .Finished
    //        }
    //    }
    
    
    
    // MARK: - Private
    
    
}