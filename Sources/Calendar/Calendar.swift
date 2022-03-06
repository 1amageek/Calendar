//
//  Calendar.swift
//  Calendar
//
//  Created by nori on 2021/09/02.
//

import SwiftUI
import RecurrenceRule
@_exported import DateExtension

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

#if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
#endif

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
#if os(iOS)
        let spacing: CGFloat = horizontalSizeClass == .compact ? 5 : 24
#else
        let spacing: CGFloat = 24
#endif
        return ForYear(data, columns: [
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing)
        ]) { date in

        }
    }

    var forMonth: some View {
        ForMonth(data) { item in
            content(item)
        }
    }

    var forWeek: some View {
        ForWeek(data, date: store.displayedDate) { item in
            content(item)
        }
    }

    var forDay: some View {
        HStack {
            ForDay(data) { item in
                content(item)
            }
            VStack {
                DatePicker("", selection: $store.displayedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                Spacer()
            }
            .frame(maxWidth: 400)
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

    struct Event: CalendarItemRepresentable, Recurrenceable {

        static func == (lhs: Event, rhs: Event) -> Bool {
            lhs.hashValue == rhs.hashValue
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(startDate)
            hasher.combine(endDate)
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

        var isAllDay: Bool = false

        var startDate: Date = Date()

        var endDate: Date = Date()

        var timeZone: TimeZone? = TimeZone.current
    }

    struct ContentView: View {

        @StateObject var store: Store = Store(displayMode: .month, today: Date())

        var events: [Event] {
            let dateComopnents = store.calendar.dateComponents(in: TimeZone.current, from: Date())
            let startDate = store.calendar.date(from: dateComopnents)! - 6.hours
            let endDate = startDate + 3.hours
            return [
                Event(id: "0", occurrenceDate: startDate, startDate: startDate, endDate: endDate),
                Event(id: "1", occurrenceDate: startDate, startDate: startDate, endDate: endDate)
            ]
        }

        func action(item: Event) {
            switch store.displayMode {

                case .day, .week: break

                case .month:
                    withAnimation {
                        store.displayMode = .week
                        store.displayedDate = item.occurrenceDate
                    }
                case .year:
                    withAnimation {
                        store.displayMode = .month
                        store.displayedDate = item.occurrenceDate
                    }
            }
        }

        var body: some View {
            VStack(spacing: 8) {
                Picker("DisplayMode", selection: $store.displayMode.animation()) {
                    ForEach(CalendarDisplayMode.allCases, id: \.self) { displaymode in
                        Text(displaymode.text)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                HStack {
                    Text(store.headerTitle)
                        .font(.title)
                        .fontWeight(.black)
                    Spacer()

                    Group {
                        Button {

                        } label: {
                            Image(systemName: "chevron.backward")
                        }

                        Button("Today") {
                            
                        }

                        Button {

                        } label: {
                            Image(systemName: "chevron.forward")
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                Calendar(events) { item in
                    Button {
                        action(item: item)
                    } label: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green)
                            .padding(1)
                    }
                }
                .environmentObject(store)
            }
        }
    }

    static var previews: some View {
        ContentView()
//            .previewInterfaceOrientation(.landscapeLeft)
    }
}
