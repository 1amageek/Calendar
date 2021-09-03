//
//  Calendar.swift
//  Calendar
//
//  Created by nori on 2021/09/02.
//

import SwiftUI

public struct Calendar: View {

    public enum DisplayMode {
        case day
        case week
        case month
        case year
    }

    @StateObject var store: Store

    public var displayMode: DisplayMode

    public init(_ displayMode: DisplayMode, today: Date, calendar: Foundation.Calendar = Foundation.Calendar(identifier: .gregorian), timeZone: TimeZone = TimeZone.current) {
        self.displayMode = displayMode
        self._store = StateObject(wrappedValue: Store(today: today, calendar: calendar, timeZone: timeZone))
    }

    public var body: some View {
        Group {
            switch displayMode {
                case .day: EmptyView()
                case .week: EmptyView()
                case .month: MonthView(firstWeekdayOfTheMonth: store.firstWeekdayOfTheMonth)
                case .year: YearView()
            }
        }
        .environmentObject(store)
    }
}

struct Calendar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Calendar(.day, today: Date())
            Calendar(.week, today: Date())
            Calendar(.month, today: Date())
            Calendar(.year, today: Date())
        }

    }
}
