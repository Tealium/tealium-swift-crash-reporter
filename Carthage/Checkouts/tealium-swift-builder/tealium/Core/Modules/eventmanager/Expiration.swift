//
//  Expiration.swift
//  TealiumSwift
//
//  Created by Christina S on 4/22/20.
//  Copyright © 2020 Tealium, Inc. All rights reserved.
//

import Foundation

public enum Expiration {
    case session
    case untilRestart
    case forever
    case after(Date)
    case afterCustom((TimeUnit, Int))

    public var date: Date {
        var components = DateComponents()
        components.calendar = Calendar.autoupdatingCurrent
        let currentDate = Date()
        switch self {
        case .after(let date):
            return date
        case .session:
            components.setValue(TealiumKey.defaultMinutesBetweenSession, for: .minute)
            return Calendar(identifier: .gregorian).date(byAdding: components, to: currentDate)!
        case .untilRestart:
            return currentDate
        case .forever:
            components.setValue(100, for: .year)
            return Calendar(identifier: .gregorian).date(byAdding: components, to: currentDate)!
        case .afterCustom((let unit, let value)):
            components.setValue(value, for: map(unit))
            return Calendar(identifier: .gregorian).date(byAdding: components, to: currentDate)!
        }
    }

    private func map(_ unit: TimeUnit) -> Calendar.Component {
        switch unit {
        case .minutes:
            return .minute
        case .hours:
            return .hour
        case .days:
            return .day
        case .months:
            return .month
        case .years:
            return .year
        }
    }

}

public enum TimeUnit {
    case minutes
    case hours
    case days
    case months
    case years
}
