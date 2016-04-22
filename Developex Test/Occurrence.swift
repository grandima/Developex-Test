//
//  Occurrences.swift
//  Developex Test
//
//  Created by Dima Medynsky on 4/22/16.
//  Copyright © 2016 Dima Medynsky. All rights reserved.
//

import Foundation

public enum CrawlStatus {
    case Downloading
    case NotFound
    case Error
    case Finished
    
}

public class Occurrence {
    
    
    
    let url: String
    public var count: Int {
        get {
            var result: Int!
            dispatch_sync(self.dynamicType.barrierQueue) {
                result = self._count
            }
            return result
        }
        set (newValue){
            dispatch_barrier_async(self.dynamicType.barrierQueue) {
                self._count = newValue
            }
        }
    }
    public var crawlStatus: CrawlStatus  {
        get {
            var result: CrawlStatus!
            dispatch_sync(self.dynamicType.barrierQueue) {
                result = self._crawlStatus
            }
            return result
        }
        set (newValue){
            dispatch_barrier_async(self.dynamicType.barrierQueue) {
                self._crawlStatus = newValue
            }
        }
    }
    
    init(url: String) {
        self.url = url
        crawlStatus = .Downloading
    }
    
    
    private static let barrierQueue = dispatch_queue_create("grandima.Developex-Occurence", DISPATCH_QUEUE_CONCURRENT)
    
    private var _count: Int = 0
    private var _crawlStatus: CrawlStatus = .Downloading
}