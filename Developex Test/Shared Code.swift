//
//  Shared Code.swift
//  Developex Test
//
//  Created by Dima Medynsky on 4/23/16.
//  Copyright © 2016 Dima Medynsky. All rights reserved.
//

import Foundation


func synchronizedOnMain(closure: () -> ()) {
    if NSThread.isMainThread() {
        closure()
    } else {
        dispatch_sync(dispatch_get_main_queue()) {
            closure()
        }
    }
}