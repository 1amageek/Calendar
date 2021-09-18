//
//  Calendar.swift
//  Calendar
//
//  Created by nori on 2021/09/02.
//

import SwiftUI
import RecurrenceRule

public enum CalendarDisplayMode: CaseIterable {
    case day
    case week
    case month
    case year

    public var text: String {
        switch self {
            case .day: return "day"
            case .week: return "week"
            case .month: return "month"
            case .year: return "year"
        }
    }
}

public struct CalendarTag: Hashable {
    public var year: Int
    public var month: Int
    public var date: Date

}

public struct Calendar<Data, Content>: View where Data: RandomAccessCollection, Data.Element: CalendarItemRepresentable, Content: View {

    @EnvironmentObject var store: Store

    var data: Data

    var content: (Data.Element) -> Content

    public init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }

    var header: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0)
        ], spacing: 0) {
            ForEach(Foundation.Calendar.current.shortWeekdaySymbols, id: \.self) { weekdaySymbol in
                VStack {
                    Text("\(weekdaySymbol)")
                        .bold()
                }
            }
        }
    }

    var forYear: some View {
        ForYear(data, columns: [
            GridItem(.flexible(), spacing: 24),
            GridItem(.flexible(), spacing: 24),
            GridItem(.flexible(), spacing: 24)
        ]) { date in

        }
    }

    var forMonth: some View {
        ForMonth(data) { item in
            content(item)
        }
    }

    var forWeek: some View {
        ForWeek(data) { item in
            content(item)
        }
    }

    var forDay: some View {
        ForDay(data) { item in
            content(item)
        }
    }

    public var body: some View {
        Group {
            switch store.displayMode {
                case .year: forYear
                case .month: forMonth
                case .week: forWeek
                default: forDay
            }
        }
        .environmentObject(store)
    }
}

struct Calendar_Previews: PreviewProvider {

    struct Event: EventRepresentable {

        static func == (lhs: Calendar_Previews.Event, rhs: Calendar_Previews.Event) -> Bool {
            lhs.hashValue == rhs.hashValue
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(title)
            hasher.combine(period)
        }

        var id: String

        var occurrenceDate: Date

        var recurrenceRules: [RecurrenceRule] = [
            RecurrenceRule(frequency: .weekly, interval: 1, daysOfTheWeek: [
                .init(dayOfTheWeek: .monday, weekNumber: 0),
                .init(dayOfTheWeek: .wednesday, weekNumber: 0),
                .init(dayOfTheWeek: .friday, weekNumber: 0)
            ])
        ]

        var title: String = ""

        var isAllDay: Bool = false

        var period: Range<Date> = Date()..<Date().date(byAdding: .day, value: 1)

        var timeZone: TimeZone = TimeZone.current
    }

    struct ContentView: View {

        @StateObject var store: Store = Store(displayMode: .week, today: Date())

        var event: Event {
            let hour = Int(24 * value)
            var dateComopnents = store.calendar.dateComponents(in: TimeZone.current, from: Date())
            dateComopnents.hour = hour
            let startDate = store.calendar.date(from: dateComopnents)!
            let period = startDate..<Date().date(byAdding: .hour, value: 4)
            return Event(id: "id", occurrenceDate: Date(), period: period)
        }

        @State var value: Float = 0

        var body: some View {
            let _ = print(Self._printChanges())
            VStack {
                Picker("DisplayMode", selection: $store.displayMode.animation()) {
                    ForEach(CalendarDisplayMode.allCases, id: \.self) { displaymode in
                        Text(displaymode.text)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                Slider(value: $value)
                Calendar(RecurrenceScheduler.calendarItems(event, range: store.displayedRange)) { date in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green)
                        .padding(1)                        
                }
                .environmentObject(store)
            }
        }
    }

    static var previews: some View {
        ContentView()
    }
}
