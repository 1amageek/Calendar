//
//  CalendarItem.swift
//  CalendarItem
//
//  Created by nori on 2021/09/16.
//

import Foundation

public struct CalendarItem: CalendarItemRepresentable, Codable {

    public var id: String

    public var isAllDay: Bool

    public var startDate: Date

    public var endDate: Date

    public var timeZone: TimeZone?

    public init(
        id: String,
        isAllDay: Bool = false,
        startDate: Date,
        endDate: Date,
        timeZone: TimeZone? = TimeZone.current
    ) {
        self.id = id
        self.isAllDay = isAllDay
        self.startDate = startDate
        self.endDate = endDate
        self.timeZone = timeZone
    }
}
