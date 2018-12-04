//
//  AppDelegate.swift
//  lianshen
//
//  Created by zatams on 2018/12/1.
//  Copyright © 2018 zatams. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SELECT_HASH_TYPE"), object: nil, userInfo: ["index":0])
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}

