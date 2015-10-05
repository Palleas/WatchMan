//
//  Watcher.swift
//  WatchMan
//
//  Created by Romain Pouclet on 2015-09-30.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import Foundation
import ReactiveCocoa
import CoreServices

class Wrapper<T>: AnyObject {
    internal let value: T

    init(_ value: T) {
        self.value = value
    }
}

public enum DirectoryWatchingError: ErrorType {
    case DirectoryDoesNotExist(String)
    case NotADirectory
}

/// This function takes a String containing the path to a folder to 
/// observe
func watchFolder(path: String) -> SignalProducer<String, DirectoryWatchingError> {
    var isDirectory: ObjCBool = true
    if !NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory) {
        return SignalProducer(error: .DirectoryDoesNotExist(path))
    } else if !isDirectory.boolValue {
        return SignalProducer(error: .NotADirectory)
    }
    
    return SignalProducer { sink, disposable in
        let flags = UInt32(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents)
        let sinceWhen: FSEventStreamEventId = UInt64(kFSEventStreamEventIdSinceNow)
        
        let eventCallback: FSEventStreamCallback = { (stream, contextInfo, numEvents, eventPaths, eventFlags, eventIds) in
            let sinkWrapper = Unmanaged<Wrapper<Signal<String, NoError>.Observer>>.fromOpaque(COpaquePointer(contextInfo)).takeUnretainedValue()
            let paths = unsafeBitCast(eventPaths, NSArray.self) as? [String]
            paths?.forEach({ sendNext(sinkWrapper.value, $0) })
        }

        let unmanaged = Unmanaged.passRetained(Wrapper(sink))
        let pointer: UnsafeMutablePointer<Void> = UnsafeMutablePointer(unmanaged.toOpaque())

        var context = FSEventStreamContext(version: 0, info: pointer, retain: nil, release: nil, copyDescription: nil)
        let eventStream = FSEventStreamCreate(kCFAllocatorDefault, eventCallback, &context, [path], sinceWhen, 3.0, flags)
        
        FSEventStreamScheduleWithRunLoop(eventStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)
        FSEventStreamStart(eventStream)
        
        disposable.addDisposable({ () -> () in
            FSEventStreamStop(eventStream)
            FSEventStreamInvalidate(eventStream)
            FSEventStreamRelease(eventStream)
        })
    }
 }