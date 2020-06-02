//
//  ViewController.swift
//  TVOSTestHost
//
//  Created by Craig Rouse on 20/11/17.
//  Copyright © 2017 Tealium, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        for idx in 1...5 {
            TVOSTealiumHelper.shared.trackView(title: "tvos_view\(idx)", data: ["testKey\(idx)": "testVal\(idx)"])
            TVOSTealiumHelper.shared.track(title: "tvos_event\(idx)", data: ["testKey\(idx)": "testVal\(idx)"])
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
