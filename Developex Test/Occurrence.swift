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

let pendingKey = "Pending"
let downloadingKey = "Downloading"
let processingKey = "Processing"


public class Occurrence {
    
    private static let barrierQueue = dispatch_get_main_queue()
    
    private var _count: Int = 0
    private var _crawlStatus: CrawlStatus = .Downloading
    
    
    let url: String
    public var count: Int {
        get {
            var result: Int!
            synchronizedOnMain {
                result = self._count
            }
            return result
        }
        set (newValue){
            synchronizedOnMain {
                self._count = newValue
                NSNotificationCenter.defaultCenter().postNotificationName("OccuranceUpdate", object: nil)
            }
        }
    }
    public var crawlStatus: CrawlStatus  {
        get {
            var result: CrawlStatus!
            synchronizedOnMain {
                result = self._crawlStatus
            }
            return result
        }
        set (newValue){
            synchronizedOnMain {
                self._crawlStatus = newValue
                NSNotificationCenter.defaultCenter().postNotificationName("OccuranceUpdate", object: nil)
            }
        }
    }
    
    init(url: String) {
        self.url = url
        crawlStatus = .Downloading
    }
    deinit {
        print("Occurrence deinit")
    }
}

protocol ViewRepresentable: class {
    var urlRepresentable: String{ get }
    var statusRepresentable: String { get }
}
extension Occurrence: ViewRepresentable {
    
    var urlRepresentable: String {
        return self.url
    }
    var statusRepresentable: String {
        switch crawlStatus {
        case .Downloading: return "Downloading"
        case .Finished: return "Finished with: " + String(self.count)
        case .NotFound: return "Not found"
        case .Error: return "Error"
        }
    }
}
