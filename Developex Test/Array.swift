//
//  Array.swift
//  Developex Test
//
//  Created by Dima Medynsky on 4/22/16.
//  Copyright © 2016 Dima Medynsky. All rights reserved.
//

import Foundation

extension SequenceType where Generator.Element == Occurrence {
    internal var notFinished: Bool {
        for e in self {
            if e.crawlStatus == .Downloading {
                return true
            }
        }
        return false
    }
}