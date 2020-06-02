//
//  AppDelegate.swift
//  OSXTestHost
//
//  Created by Craig Rouse on 20/11/17.
//  Copyright © 2017 Tealium, Inc. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        OSXTealiumHelper.shared.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}
