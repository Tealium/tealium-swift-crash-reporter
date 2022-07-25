//
//  CrashConstants.swift
//  TealiumCrashModule
//
//  Copyright © 2020 Tealium, Inc. All rights reserved.
//

import Foundation

public enum CrashKey {
    public static let moduleName = "crash"
    public static let count = "crash_count"

    enum ImageThread {
        static let baseAddress = "baseAddress"
        static let imageName = "imageName"
        static let imageUuid = "imageUuid"
        static let imageSize = "imageSize"
        static let codeType = "codeType"
        static let architecture = "arch"
        static let typeEncoding = "typeEncoding"
        static let registers = "registers"
        static let crashed = "crashed"
        static let threadId = "threadId"
        static let threadNumber = "threadNumber"
        static let priority = "priority"
        static let stack = "stack"
        static let instructionPointer = "instructionPointer"
        static let symbolInfo = "symbolInfo"
        static let symbolName = "symbolName"
        static let symbolStartAddress = "symbolStartAddr"
    }

}
