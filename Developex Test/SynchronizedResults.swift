//
//  SynchronizedResults.swift
//  Developex Test
//
//  Created by Dima Medynsky on 4/23/16.
//  Copyright © 2016 Dima Medynsky. All rights reserved.
//

import Foundation


//
public class SynchronizedResults<T: Occurrence> {
    private var _results = [T]()
    
    init() {
        synchronizedOnMain {
            self._results = []
        }
    }
    
    func markResults(withStatus status: Status) {
        synchronizedOnMain {
            (self._results.filter{$0.crawlStatus != .Finished(FinishEnum.NotFound)}).forEach{$0.crawlStatus = status}
        }
    }
    
    func append(t: T) {
        synchronizedOnMain {
            self._results.append(t)
            NSNotificationCenter.defaultCenter().postNotificationName(Occurrence.updateNotification, object: nil)
        }
    }
    
    func removeAll() {
        synchronizedOnMain {
            self._results = []
            NSNotificationCenter.defaultCenter().postNotificationName(Occurrence.updateNotification, object: nil)
        }
    }
    
    subscript (i: Int) -> T{
        get {
            var result: T!
            synchronizedOnMain {
                result = self._results[i]
            }
            return result
        }
        set(newValue) {
            synchronizedOnMain {
                self._results[i] = newValue
                NSNotificationCenter.defaultCenter().postNotificationName(Occurrence.updateNotification, object: nil)
            }
        }
    }
    
    func occures(url: String) -> Bool {
        var occured = false
        synchronizedOnMain {
            for item in self._results {
                if item.url == url {
                    occured = true
                    break
                }
            }
        }
        return occured
    }
    
    var count: Int {
        var result: Int!
        synchronizedOnMain {
            result = self._results.count
        }
        return result
    }
    func countForStatus(forStatus status: Status) -> Int {
        var result: Int!
        synchronizedOnMain {
            result = (self._results.filter{$0.crawlStatus == status}).count
        }
        return result
    }
    
    var notFinished: Bool {
        var result = false
        synchronizedOnMain {
            for e in self._results {
                if e.crawlStatus == .InProcess(ProgressEnum.Downloading) ||  e.crawlStatus == .Added {
                    result = true
                }
            }
            if !result {
                NSNotificationCenter.defaultCenter().postNotificationName(CrawlManager.statusNotification, object: nil, userInfo: ["status": "Finished"])
            }
        }
        return result
    }
    
    //MARK: - Private
    
    private var _count: Int = 0
    private var _crawlStatus: Status = .InProcess(ProgressEnum.Pending)
    
}