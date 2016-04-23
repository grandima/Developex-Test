//
//  SynchronizedResults.swift
//  Developex Test
//
//  Created by Dima Medynsky on 4/23/16.
//  Copyright © 2016 Dima Medynsky. All rights reserved.
//

import Foundation

public class SynchronizedResults<T: Occurrence> {
    private var _results = [T]()
    
    init() {
        synchronizedOnMain {
            self._results = []
            //NSNotificationCenter.defaultCenter().postNotificationName("OccuranceUpdate", object: nil)
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
                NSNotificationCenter.defaultCenter().postNotificationName("OccuranceUpdate", object: nil)
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
    
    
    func append(t: T) {
        synchronizedOnMain {
            self._results.append(t)
            NSNotificationCenter.defaultCenter().postNotificationName("OccuranceUpdate", object: nil)
        }
    }
    
    func clear() {
        synchronizedOnMain {
            self._results = []
            NSNotificationCenter.defaultCenter().postNotificationName("OccuranceUpdate", object: nil)
        }
    }
    
    var count: Int {
        var result: Int!
        synchronizedOnMain {
            result = self._results.count
        }
        return result
    }
    
    var notFinished: Bool {
        var result = false
        synchronizedOnMain {
            for e in self._results {
                if e.crawlStatus == .Downloading {
                    result = true
                }
            }
            if !result {
                NSNotificationCenter.defaultCenter().postNotificationName("Finished", object: nil)
            }
        }
        return result
        
    }
}