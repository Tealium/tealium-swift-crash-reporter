//
//  ViewController.swift
//  OSXTestHost
//
//  Created by Craig Rouse on 20/11/17.
//  Copyright © 2017 Tealium, Inc. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        }
    }
    @IBAction func trackViewPressed(_ sender: Any) {
        OSXTealiumHelper.shared.trackView(title: "osx_view", data: ["testKey": "testVal"])
    }
    
    @IBAction func trackEventPressed(_ sender: Any) {
        OSXTealiumHelper.shared.track(title: "osx_event", data: ["testKey": "testVal"])
    }
}
