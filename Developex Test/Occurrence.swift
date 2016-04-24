//
//  Occurrences.swift
//  Developex Test
//
//  Created by Dima Medynsky on 4/22/16.
//  Copyright © 2016 Dima Medynsky. All rights reserved.
//

import Foundation

//Keeps URL and its status (see `StatusEnums.swift`)
public class Occurrence {
    
    public static let updateNotification = "OccurrenceUpdate"
    
    public let url: String
    
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
                NSNotificationCenter.defaultCenter().postNotificationName(self.dynamicType.updateNotification, object: nil)
            }
        }
    }
    public var crawlStatus: Status  {
        get {
            var result: Status!
            synchronizedOnMain {
                result = self._crawlStatus
            }
            return result
        }
        set (newValue){
            synchronizedOnMain {
                self._crawlStatus = newValue
                NSNotificationCenter.defaultCenter().postNotificationName(Occurrence.updateNotification, object: nil)
            }
        }
    }
    init(url: String) {
        self.url = url
        _crawlStatus = .Added
    }
    
    deinit {
        print("Occurrence deinit")
    }
    
    //MARK: - Privage
    
    private var _count: Int = 0
    private var _crawlStatus: Status = .InProcess(ProgressEnum.Pending)
}

extension Occurrence: Equatable {}

public func ==(lhs: Occurrence, rhs: Occurrence) -> Bool {
    var result: Bool!
    synchronizedOnMain {
        result = lhs.url == rhs.url
    }
    return result
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
            return crawlStatus.description
    }
}
