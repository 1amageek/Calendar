//
//  DateRange.swift
//  DateRange
//
//  Created by nori on 2021/09/10.
//

import Foundation
import SwiftUI

extension Date {

    public var dayTag: String { DateTag.day(self).id }
    public var weekOfYearTag: String { DateTag.weekOfYear(self).id }
    public var monthTag: String { DateTag.month(self).id }
    public var yearTag: String { DateTag.year(self).id }
}

public enum DateTag {

    case day(Date)
    case weekOfYear(Date)
    case month(Date)
    case year(Date)

    var id: String {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        switch self {
            case .day(let date):
                let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                return "\(dateComponents.year!)-\(dateComponents.month!)-\(dateComponents.day!)"
            case .weekOfYear(let date):
                let dateComponents = calendar.dateComponents([.yearForWeekOfYear, .year, .weekOfYear], from: date)
                return "\(dateComponents.year!)-\(dateComponents.weekOfYear!)"
            case .month(let date):
                let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                return "\(dateComponents.year!)-\(dateComponents.month!)"
            case .year(let date):
                let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                return "\(dateComponents.year!)"
        }
    }
}

public struct DateRange {

    var calendar: Foundation.Calendar

    var component: Component

    var startDay: Date

    var date: Date = Date()

    var value: Int = 0

    public var range: Range<Int>

    public var dateRange: Range<Date> { (lowerBound..<upperBound) }

    public var lowerBound: Date {
        return calendar.date(byAdding: component.rawValue, value: range.lowerBound, to: startDay)!
    }

    public var upperBound: Date {
        return calendar.date(byAdding: component.rawValue, value: range.upperBound, to: startDay)!
    }

    @inlinable public func contains(_ element: Date) -> Bool { lowerBound <= element && element < upperBound }

    @inlinable public var isEmpty: Bool { lowerBound == upperBound }

    public init(_ date: Date = Date(), range: Range<Int>, component: Component = .day) {
        self.date = date
        self.range = range
        self.component = component
        let calendar = Foundation.Calendar(identifier: .gregorian)
        var dateComponents: DateComponents
        switch component {
            case .year: dateComponents = calendar.dateComponents([.calendar, .timeZone, .year], from: date)
            case .month: dateComponents = calendar.dateComponents([.calendar, .timeZone, .year, .month], from: date)
            case .day: dateComponents = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
            case .hour: dateComponents = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day, .hour], from: date)
            case .minute: dateComponents = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day, .hour, .minute], from: date)
            case .second: dateComponents = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day, .hour, .minute, .second], from: date)
            case .weekOfYear: dateComponents = calendar.dateComponents([.calendar, .timeZone, .yearForWeekOfYear, .weekOfYear], from: date)
            case .weekOfMonth: dateComponents = calendar.dateComponents([.calendar, .timeZone, .yearForWeekOfYear, .weekOfYear, .weekOfMonth], from: date)
        }
        self.calendar = calendar
        self.startDay = calendar.date(from: dateComponents)!
    }

    public static func year(range: Range<Int>) -> Self {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        let dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current, year: range.lowerBound)
        let date = calendar.date(from: dateComponents)!
        let lowerBound = 0
        let upperBound = range.upperBound - range.lowerBound
        return DateRange(date, range: (lowerBound..<upperBound), component: .year)
    }

    public static func weekOfYear(year: Int) -> Self {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        let dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current, year: year)
        let date = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .weekOfYear, in: .year, for: date)!
        return DateRange(date, range: range, component: .weekOfYear)
    }
}

extension DateRange {

    public enum Component {

        case year
        case month
        case weekOfMonth
        case weekOfYear
        case day
        case hour
        case minute
        case second

        var rawValue: Foundation.Calendar.Component {
            switch self {
                case .year: return .year
                case .month: return .month
                case .weekOfYear: return .weekOfYear
                case .weekOfMonth: return .weekOfMonth
                case .day: return .day
                case .hour: return .hour
                case .minute: return .minute
                case .second: return .second
            }
        }
    }
}

extension DateRange: Sequence {

    public struct DateIterator: IteratorProtocol {

        var calendar: Foundation.Calendar

        var component: Component

        var date: Date

        var range: Range<Int>

        var position: Int

        init(calendar: Foundation.Calendar, component: Component, date: Date, range: Range<Int>) {
            self.calendar = calendar
            self.component = component
            self.date = date
            self.range = range
            self.position = range.lowerBound
        }

        public mutating func next() -> Date? {
            defer { position += 1 }
            if range.contains(position) {
                return calendar.date(byAdding: component.rawValue, value: position, to: date)
            }
            return nil
        }
    }

    public typealias Iterator = DateIterator

    public __consuming func makeIterator() -> DateIterator {
        DateIterator(calendar: calendar, component: component, date: startDay, range: range)
    }
}

extension DateRange: Collection {

    public typealias Index = Int

    public subscript(position: Int) -> Date {
        get { calendar.date(byAdding: component.rawValue, value: position, to: startDay)! }
    }

    public func index(after i: Int) -> Int {
        i + 1
    }

    public var startIndex: Int {
        return self.range.lowerBound
    }

    public var endIndex: Int {
        return self.range.upperBound
    }
}

extension DateRange: BidirectionalCollection {

    public func index(before i: Int) -> Int {
        i - 1
    }

}

extension DateRange: RandomAccessCollection { }

extension ForEach where Data == DateRange, ID == Date, Content: View {

    public init(_ data: Data, @ViewBuilder content: @escaping (Date) -> Content) {
        self.init(data, id: \.self, content: content)
    }
}
