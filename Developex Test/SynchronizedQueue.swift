//
//  SynchronizedQueue.swift
//  Developex Test
//
//  Created by Dima Medynsky on 4/22/16.
//  Copyright © 2016 Dima Medynsky. All rights reserved.
//

import Foundation

public class SynchronizedQueue<T: Equatable> {
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
    
    public var firstElement: T? {
        var element: T? = nil
        dispatch_sync(self.accessQueue) {
            if self.queue.count != 0 {
                element = self.queue.first
            }
        }
        return element
    }
    
    public func postponedPop(matchingClosure: (T) -> Bool) -> T? {
        var element: T? = nil
        dispatch_sync(self.accessQueue) {
            for e in self.queue {
                if matchingClosure(e) {
                    element = e
                    break
                }
            }
        }
        return element
    }
    public func remove(elementToRemove: T) {
        dispatch_sync(self.accessQueue) {
            var index: Int?
            for (idx, obj) in self.queue.enumerate() {
                if obj == elementToRemove {
                    index = idx
                }
            }
            if index != nil {
                self.queue.removeAtIndex(index!)
            }
        }
        
    }
    public func removeAll() {
        dispatch_sync(self.accessQueue) { 
            self.queue = []
        }
    }
    
}