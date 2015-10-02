//
//  AppDelegate.swift
//  WatchMan
//
//  Created by Romain Pouclet on 2015-09-30.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(aNotification: NSNotification) {

        watchFolder(NSHomeDirectory() + "/PrintMe").startWithNext { (file) -> () in
            print("File changed : \(file)")
        }
    }

}

