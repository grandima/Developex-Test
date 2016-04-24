//
//  CrawlManager.swift
//  Developex Test
//
//  Created by Dima Medynsky on 4/21/16.
//  Copyright © 2016 Dima Medynsky. All rights reserved.
//

import Foundation
//enum URLCrawlState {
//    case Downloading, Found(Int), NotFound, Error
//}

public class CrawlManager {
    //MARK: - Private
    private var privateQueue = dispatch_queue_create("grandima.Developex-Test.CrawlManager.Private", DISPATCH_QUEUE_CONCURRENT)
    public var pendingURLs = SynchronizedQueue<Occurrence>()
    public var results = SynchronizedResults<Occurrence>()
    private var _stopped = false
    private var suspended: Bool = false
    private var operationQueue: NSOperationQueue!
    
    //MARK: - Public
    
    public static let sharedManager = CrawlManager()
    
    public var stopped: Bool {
        get {
            var value: Bool!
            synchronizedOnMain {
                value = self._stopped
            }
            return value
        }
        set (newValue) {
            synchronizedOnMain {
                self._stopped = newValue
            }
        }
    }

    
    public func addURL(url: String) {
        synchronizedOnMain {
            if self.results.count < Settings.maxURLNumber && !self._stopped {
                if !self.results.occures(url) {
                    let occurance = Occurrence(url: url)
                    self.pendingURLs.push(occurance)
                    self.results.append(occurance)
                }
            }
        }
    }
    
    
    
    func start(url: String) {
    
        dispatch_async(privateQueue) {[unowned self] in
            self.configure()
            self.addURL(url)
            
            let queue = self.operationQueue
            while !self.stopped && self.results.notFinished && self.results.count <= Settings.maxURLNumber {
            
                guard let occurance = self.pendingURLs.pop() else { continue }

                let operation = CrawlOperation(occurrence: occurance)
                queue.addOperation(operation)
                
            }
        }
    }
    
    func configure() {
        operationQueue = NSOperationQueue()
        operationQueue.maxConcurrentOperationCount = Settings.maxConcurrentOperationCount
        
        stopped = false
        
    }
    
    func stop() {
        stopped = true
        operationQueue.cancelAllOperations()
        pendingURLs.clear()
        results.clear()
    }
    
//    func completionHandler(occurrence: Occurrence, data: NSData?, error: NSError?) {
//        
//        guard let data = data where error == nil else {
//            occurrence.crawlStatus = .Error
//            return
//        }
//        
//        if let text = String(data: data, encoding: NSUTF8StringEncoding) {
//            
//            let links = text.links
//            links.forEach{ self.addURL($0) }
//            
//            //TODO: - Tell about a problem
//            let withoutHTML = text.withoutHTML
//            let occurrenceCount = withoutHTML.occurences(ofSubString: Settings.textToFind)
//            
//            if occurrenceCount > 0 {
//                occurrence.count = occurrenceCount
//                occurrence.crawlStatus = .Finished
//            } else {
//                occurrence.crawlStatus = .NotFound
//            }
//
//        }
//        else {
//            occurrence.crawlStatus = .Error
//        }
//    }
    
    //    private func setCount(item: Occurrence, count: Int) {
    //        dispatch_barrier_sync(barrierQueue) {
    //            item.count = count
    //            item.crawlStatus = .Finished
    //        }
    //    }
    
    
    
    // MARK: - Private
    
    
}