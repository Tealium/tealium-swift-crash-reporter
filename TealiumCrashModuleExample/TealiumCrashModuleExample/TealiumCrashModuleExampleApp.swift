//
//  TealiumCrashModuleExampleApp.swift
//  TealiumCrashModuleExample
//
//  Created by Enrico Zannini on 19/07/22.
//

import SwiftUI
import TealiumSwift
import TealiumCrashModule

@main
struct TealiumCrashModuleExampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
var tealium: Tealium!
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        

        let config = TealiumConfig(account: "tealiummobile",
                                   profile: "demo",
                                   environment: "dev",
                                   dataSource: "test12")

        // add desired Collectors - no need to include if want compiled Collectors
        config.collectors = [Collectors.AppData,
                             Collectors.Crash,] // Instantiates the CrashReporter module
        config.dispatchers = [Dispatchers.Collect]
        config.sendCrashDataOnCrashDetected = true
        tealium = Tealium(config: config) { _ in }
        return true
    }
}
