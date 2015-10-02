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

func watchFolder(path: String) -> SignalProducer<String, NoError> {
    return SignalProducer { sink, disposable in
        let flags = UInt32(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents)
        let sinceWhen: FSEventStreamEventId = UInt64(kFSEventStreamEventIdSinceNow)
        
        let eventCallback: FSEventStreamCallback = { (stream, contextInfo, numEvents, eventPaths, eventFlags, eventIds) in
            print("***** FSEventCallback Fired *****")
        }

        var name: String = "romain"
        var context = FSEventStreamContext(version: 0, info: &name, retain: nil, release: nil, copyDescription: nil)
        let eventStream = FSEventStreamCreate(kCFAllocatorDefault, eventCallback, &context, [path], sinceWhen, 3.0, flags)
        
        FSEventStreamScheduleWithRunLoop(eventStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)
        FSEventStreamStart(eventStream)
        
        disposable.addDisposable({ () -> () in
            print("Disposing of event stream...")
        })
    }
 }