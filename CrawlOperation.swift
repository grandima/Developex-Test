//
//  CrawlOperation.swift
//  Developex Test
//
//  Created by Dima Medynsky on 4/23/16.
//  Copyright © 2016 Dima Medynsky. All rights reserved.
//

import Foundation
class CrawlOperation : ConcurrentOperation {
    
    // define properties to hold everything that you'll supply when you instantiate
    // this object and will be used when the request finally starts
    //
    // in this example, I'll keep track of (a) URL; and (b) closure to call when request is done
    
    weak var occurrence: Occurrence?
    let url: NSURL
    
    weak var task: NSURLSessionDataTask?
    // we'll also keep track of the resulting request operation in case we need to cancel it later
    
    //weak var request: Alamofire.Request?
    
    // define init method that captures all of the properties to be used when issuing the request
    
    init(occurrence: Occurrence, networkOperationCompletionHandler: (occurrence: Occurrence, responseObject: NSData?, error: NSError?) -> ()) {
        self.occurrence = occurrence

        url = NSURL(string: occurrence.url) ?? NSURL()
        super.init()
    }
    
    // when the operation actually starts, this is the method that will be called
    
    override func main() {
        let dataTask = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { [weak occurrence](data, response, error) in
            guard let data = data where error == nil else {
                occurrence?.crawlStatus = .Error
                return
            }
            if self.cancelled {
                self.completeOperation()
            }
            
            if let text = String(data: data, encoding: NSUTF8StringEncoding) {
                if self.cancelled {
                    self.completeOperation()
                    return
                }
                let links = text.links
                if self.cancelled {
                    self.completeOperation()
                    return
                }
                links.forEach{ CrawlManager.sharedManager.addURL($0) }
                if self.cancelled {
                    self.completeOperation()
                    return
                }
                //TODO: - Tell about a problem
                let withoutHTML = text.withoutHTML
                let occurrenceCount = withoutHTML.occurences(ofSubString: Settings.textToFind)
                if self.cancelled {
                    self.completeOperation()
                    return
                }
                if occurrenceCount > 0 {
                    occurrence?.count = occurrenceCount
                    occurrence?.crawlStatus = .Finished
                } else {
                    occurrence?.crawlStatus = .NotFound
                }
                
            }
            else {
                occurrence?.crawlStatus = .Error
            }
            
            // now that I'm done, complete this operation
            self.completeOperation()
            
        })
        task = dataTask
        task?.resume()
        
    }
    
    
    override func cancel() {
        task?.cancel()
        super.cancel()
    }
}