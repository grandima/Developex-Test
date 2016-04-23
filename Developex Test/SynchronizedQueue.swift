//
//  SynchronizedQueue.swift
//  Developex Test
//
//  Created by Dima Medynsky on 4/22/16.
//  Copyright © 2016 Dima Medynsky. All rights reserved.
//

import Foundation

public class SynchronizedQueue<T> {
    private var queue: [T] = []
    private let accessQueue = dispatch_queue_create("grandima.Developex-SynchronizedQueue", DISPATCH_QUEUE_SERIAL)
    
    public func push(newElement: T) {
        dispatch_async(self.accessQueue) {
            self.queue.append(newElement)
        }
    }
    public func pop() -> T? {
        var element: T? = nil
        dispatch_sync(self.accessQueue) {
            if self.queue.count != 0 {
                element = self.queue.removeFirst()
            }
        }
        return element
    }
    public func clear() {
        dispatch_sync(self.accessQueue) { 
            self.queue = []
        }
    }
    
}