//
//  CalendarItem.swift
//  CalendarItem
//
//  Created by nori on 2021/09/16.
//

import Foundation


public struct CalendarItem: CalendarItemRepresentable {

    public var id: String

    public var title: String

    public var isAllDay: Bool

    public var period: Range<Date>

    public var location: String?

    public var url: URL?

    public var timeZone: TimeZone

    public init(
        id: String,
        title: String = "NO TITLE",
        isAllDay: Bool = false,
        period: Range<Date>,
        location: String? = nil,
        url: URL? = nil,
        timeZone: TimeZone = TimeZone.current
    ) {
        self.id = id
        self.title = title
        self.isAllDay = isAllDay
        self.period = period
        self.location = location
        self.url = url
        self.timeZone = timeZone
    }
}

//extension CalendarItem {
//
//    public static func == (lhs: CalendarItem, rhs: CalendarItem) -> Bool {
//        lhs.period == rhs.period
//    }
//}
//
//extension CalendarItem {
//
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//        hasher.combine(title)
//        hasher.combine(location)
//        hasher.combine(timeZone)
//        hasher.combine(url)
//        hasher.combine(isAllDay)
//        hasher.combine(period)
//    }
//}
