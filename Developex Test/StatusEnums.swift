//
//  StatusEnums.swift
//  Developex Test
//
//  Created by Dima Medynsky on 4/24/16.
//  Copyright © 2016 Dima Medynsky. All rights reserved.
//

import Foundation

public enum ErrorEnum: ErrorType {
    case Download
    case Process
    
}

extension ErrorEnum: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Download: return "Download error"
        case .Process: return "Process error"
        }
    }
}

public enum FinishEnum {
    case Error(ErrorEnum)
    case Found(Int)
    case NotFound
}

extension FinishEnum: CustomStringConvertible {
    public var description: String {
        switch self {
        case Error(let e): return e.description
        case .Found(let count): return "Found: \(count)"
        case .NotFound: return "Not found"
        }
    }
}

public enum ProgressEnum: String {
    case Pending
    case Downloading
    case Processing
}
extension ProgressEnum: CustomStringConvertible {
    public var description: String {
        return self.rawValue
    }
}

public enum Status {
    case Added
    case InProcess(ProgressEnum)
    case Finished(FinishEnum)
}

extension Status: CustomStringConvertible {
    public var description: String {
        switch self {
        case .InProcess(let progress): return progress.description
        case .Finished(let finish): return finish.description
        case .Added: return "Added"
        }
    }
}

extension Status: Equatable {}

public func ==(lhs: Status, rhs: Status) -> Bool {
    switch (lhs, rhs) {
    case (.InProcess(_), .InProcess(_)): return true
    case (.Finished(_), .Finished(_)): return true
    case (.Added, .Added): return true
    default: return false
    }
}



