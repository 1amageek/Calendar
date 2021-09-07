//
//  Date+Time.swift
//  Date+Time
//
//  Created by nori on 2021/09/05.
//

import Foundation

extension Date {

    public var time: Int { Int(floor(self.timeIntervalSince1970)) }

    public func date(dayOfWeek: Int) -> Date {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        let dateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        let startDay = calendar.date(from: dateComponents)!
        return calendar.date(byAdding: .day, value: dayOfWeek, to: startDay)!
    }

    public func date(byAdding: Foundation.Calendar.Component, value: Int) -> Date {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        return calendar.date(byAdding: byAdding, value: value, to: self)!
    }

    public func date(dateComponents: Set<Foundation.Calendar.Component>) -> Date {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        let dateComponents = calendar.dateComponents(dateComponents, from: self)
        return calendar.date(from: dateComponents)!
    }
}

extension Range where Bound == Date {
    public var time: Range<Int> { self.lowerBound.time..<self.upperBound.time }
}

extension Int {
    public var date: Date { Date(timeIntervalSince1970: TimeInterval(self)) }
}
