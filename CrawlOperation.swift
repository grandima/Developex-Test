//
//  CrawlOperation.swift
//  Developex Test
//
//  Created by Dima Medynsky on 4/23/16.
//  Copyright © 2016 Dima Medynsky. All rights reserved.
//

import Foundation
class CrawlOperation : ConcurrentOperation {
    
    
    init(occurrence: Occurrence) {
        self.occurrence = occurrence
        self.occurrence?.crawlStatus = .InProcess(ProgressEnum.Pending)
        let stringURL = occurrence.url ?? ""
        url = NSURL(string: stringURL) ?? NSURL()
        super.init()
    }

    override func main() {
        occurrence?.crawlStatus = .InProcess(ProgressEnum.Downloading)
        
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { [weak occurrence](data, response, error) in
            
            occurrence?.crawlStatus = .InProcess(ProgressEnum.Processing)
            
            guard let data = data where error == nil else {
                if let error = error {
                    if error.code == -999 {
                        if self.cancelled {
                            self.completeOperation()
                            return
                        }
                        return
                    } else {
                        self.setFinishedStatus(.Error(.Download))
                        self.completeOperation()
                        return
                    }
                }
                else {
                    if self.cancelled {
                        self.completeOperation()
                        return
                    }
                    self.setFinishedStatus(.Error(.Download))
                    return
                }
            }
            
            if self.cancelled {
                self.completeOperation()
                return
            }
            
            if let text = String(data: data, encoding: NSUTF8StringEncoding) {
                
                if self.cancelled {
                    self.completeOperation()
                    return
                }
                
                let links = text.links
                links.forEach{ CrawlManager.sharedManager.addURL($0) }
                
                if self.cancelled {
                    self.completeOperation()
                    return
                }
                
                //TODO: - The problem is that I loop through the whole HTML text but not text without HTML tags.
                //This is because NSAttributedString can't work with NSHTMLTextDocumentType in background thread.
                //Instead, it starts running in main thread and causes runtime error.
                let withoutHTML = text//.withoutHTML
                let occurrenceCount = withoutHTML.occurences(ofSubString: Settings.sharedSettings.textToFind)
                
                
                if self.cancelled {
                    self.completeOperation()
                    return
                }
                
                if occurrenceCount > 0 {
                    self.setFinishedStatus(.Found(occurrenceCount))
                    
                } else {
                    self.setFinishedStatus(.NotFound)
                }
                
            }
            else {
                self.setFinishedStatus(.Error(.Process))
            }
            
            self.completeOperation()
            
            })
        task = dataTask
        task?.resume()
        
    }
    
    override func cancel() {
        task?.cancel()
        super.cancel()
    }
    
    //MARK: - Private
    
    private let url: NSURL
    weak private var occurrence: Occurrence?
    weak private var task: NSURLSessionDataTask?
    
    private func setFinishedStatus(finish: FinishEnum) {
        occurrence?.crawlStatus = .Finished(finish)
        guard let unwrOccurrence = occurrence else { return }
        CrawlManager.sharedManager.pendingURLs.remove(unwrOccurrence)
        synchronizedOnMain {
            NSNotificationCenter.defaultCenter().postNotificationName(CrawlManager.progressChangedNotification, object: nil)
        }
    }
}