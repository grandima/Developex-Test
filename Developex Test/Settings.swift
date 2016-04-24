//
//  Settings.sharedSettings.swift
//  Developex Test
//
//  Created by Dima Medynsky on 4/21/16.
//  Copyright © 2016 Dima Medynsky. All rights reserved.
//

import Foundation

class Settings {
    static let sharedSettings = Settings()
    
    init () {
        _startURL = ""
        _maxConcurrentOperationCount = 1
        _textToFind = ""
        _maxURLNumber = 1
    }
    
    var startURL: String {
        get {
            var value: String!
            synchronizedOnMain {
                value = self._startURL
            }
            return value
        }
        set (newValue){
            synchronizedOnMain {
                self._startURL = newValue
            }
        }
    }
    
    var maxConcurrentOperationCount: Int {
        get {
            var value: Int!
            synchronizedOnMain {
                value = self._maxConcurrentOperationCount
            }
            return value
        }
        set (newValue){
            synchronizedOnMain {
                self._maxConcurrentOperationCount = newValue
            }
        }
    }
    
    var textToFind: String {
        get {
            var value: String!
            synchronizedOnMain {
                value = self._textToFind
            }
            return value
        }
        set (newValue){
            synchronizedOnMain {
                self._textToFind = newValue
            }
        }
    }
    
    var maxURLNumber: Int {
        get {
            var value: Int!
            synchronizedOnMain {
                value = self._maxURLNumber
            }
            return value
        }
        set (newValue){
            synchronizedOnMain {
                self._maxURLNumber = newValue
            }
        }
    }
    
    private var _startURL: String
    private var _maxConcurrentOperationCount: Int
    private var _textToFind: String
    private var _maxURLNumber: Int
}
