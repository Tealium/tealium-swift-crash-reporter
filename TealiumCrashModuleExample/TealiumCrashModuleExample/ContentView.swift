//
//  ContentView.swift
//  TealiumCrashModuleExample
//
//  Created by Enrico Zannini on 19/07/22.
//

import SwiftUI
import TealiumSwift
import TealiumCrashModule

struct ContentView: View {
    var body: some View {
        Group {
            Button {
                tealium.track(TealiumEvent("Some Event"))
            } label: {
                Text("Track")
            }.padding()
            Button {
                CrashReporter.invokeCrash(name: "asd", reason: "asd")
//                NSException.raise(NSExceptionName("Exception"),
//                                  format: "This is a test exception",
//                                  arguments: getVaList(["nil"]))
            } label: {
                Text("CRASH!!!")
            }.padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
