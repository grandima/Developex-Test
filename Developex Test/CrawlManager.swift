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

    //MARK: - Public
    
    public static let progressChangedNotification = "ProgressChanged"
    public static let statusNotification = "StatusNotification"
    
    public static let sharedManager = CrawlManager()
    
    public var pendingURLs = SynchronizedQueue<Occurrence>()
    public var results = SynchronizedResults<Occurrence>()

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
    public var paused: Bool {
        get {
            var value: Bool!
            synchronizedOnMain {
                value = self._paused
            }
            return value
        }
        set (newValue) {
            synchronizedOnMain {
                self._paused = newValue
            }
        }
    }

    public func addURL(url: String) {
        synchronizedOnMain {
            if (self.results.count < Settings.sharedSettings.maxURLNumber) && ((!self._stopped && self._paused) || (self._stopped == false && self._paused == false)){
                if !self.results.occures(url) {
                    let occurrence = Occurrence(url: url)
                    self.pendingURLs.push(occurrence)
                    self.results.append(occurrence)
                }
            }
        }
    }
    
    public func start(url: String) {
        self.stopped = true
        self.operationQueue?.cancelAllOperations()
        self.operationQueue?.waitUntilAllOperationsAreFinished()
        self.pendingURLs.removeAll()
        self.results.removeAll()
        
        self.configure()
        self.addURL(url)
        self.resume()
    }
    
    public func resume() {
        dispatch_async(privateQueue) {[unowned self] in
            self.stopped = false
            self.paused = false
            while !self.stopped && !self.paused && self.results.notFinished && self.results.count <= Settings.sharedSettings.maxURLNumber {
                guard let occurrence = self.pendingURLs.postponedPop({ (occ: Occurrence) -> Bool in
                    return occ.crawlStatus == .Added
                }) else { continue }
                let operation = CrawlOperation(occurrence: occurrence)
                self.operationQueue?.addOperation(operation)
            }
        }
    }
    
    public func pause() {
        dispatch_async(privateQueue) {[unowned self] in
            synchronizedOnMain({
                NSNotificationCenter.defaultCenter().postNotificationName(self.dynamicType.statusNotification, object: nil, userInfo: ["status": "Pausing"])
            })
            self.paused = true
            self.operationQueue?.cancelAllOperations()
            self.operationQueue?.waitUntilAllOperationsAreFinished()
            synchronizedOnMain({
                NSNotificationCenter.defaultCenter().postNotificationName(self.dynamicType.statusNotification, object: nil, userInfo: ["status": "Paused"])
            })
            self.results.markResults(withStatus: .Added)
        }
    }
    
    public func stop() {
        dispatch_async(privateQueue) {[unowned self] in
            synchronizedOnMain({
                NSNotificationCenter.defaultCenter().postNotificationName(self.dynamicType.statusNotification, object: nil, userInfo: ["status": "Stoping"])
            })
            
            self.stopped = true
            self.operationQueue?.cancelAllOperations()
            self.operationQueue?.waitUntilAllOperationsAreFinished()
            synchronizedOnMain({
                NSNotificationCenter.defaultCenter().postNotificationName(self.dynamicType.statusNotification, object: nil, userInfo: ["status": "Stopped"])
            })
            
            self.pendingURLs.removeAll()
            self.results.removeAll()
        }
        
    }
    
    //MARK: - Private
    
    private var privateQueue = dispatch_queue_create("grandima.Developex-Test.CrawlManager.Private", DISPATCH_QUEUE_CONCURRENT)
    
    private var _stopped = false
    private var _paused = false
    private var operationQueue: NSOperationQueue?
    
    private func configure() {
        operationQueue = NSOperationQueue()
        operationQueue?.maxConcurrentOperationCount = Settings.sharedSettings.maxConcurrentOperationCount
        stopped = false
        
    }
    
    
    
}