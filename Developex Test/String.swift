//
//  Extensions.swift
//  Developex Test
//
//  Created by Dima Medynsky on 4/22/16.
//  Copyright © 2016 Dima Medynsky. All rights reserved.
//

import UIKit



extension String {
    
    internal func occurences(ofSubString subString: String) -> Int {
        guard let regex = try? NSRegularExpression(pattern: subString, options: []) else { return 0 }
        let ranges = regex.matchesInString(self, options: [], range: NSMakeRange(0, self.characters.count)).map {$0.range}
        return ranges.count
    }
    
    internal var withoutHTML: String {
        guard let data = self.dataUsingEncoding(NSUTF8StringEncoding) else { return "" }
        let attrString = try? NSAttributedString(data: data, options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil)
        return attrString?.string ?? ""
    }
    
    internal var links: [String] {
        
        let types: NSTextCheckingType = .Link
        guard let detector = try? NSDataDetector(types: types.rawValue) else { return [] }
        var matchSet = Set<String>()
        detector.enumerateMatchesInString(self, options: .ReportCompletion, range: NSMakeRange(0, self.characters.count)) { (result, flags, false) in
            
            guard let url = result?.URL else { return }
            if url.scheme == "http" {
                guard let components = NSURLComponents(string: url.absoluteString) else { return }
                components.scheme = "https"
                guard let stringFromComponents = components.URL?.absoluteString else { return }
                if !matchSet.contains(stringFromComponents) {
                    matchSet.insert(url.absoluteString)
                }
                
            } else if url.scheme == "https" {
                guard let components = NSURLComponents(string: url.absoluteString) else { return }
                components.scheme = "http"
                guard let stringFromComponents = components.URL?.absoluteString else { return }
                if matchSet.contains(stringFromComponents) {
                    matchSet.remove(stringFromComponents)
                }
                matchSet.insert(url.absoluteString)
            }
        }
        return Array(matchSet)
        
    }
}