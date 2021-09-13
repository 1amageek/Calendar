//
//  Calendar.swift
//  Calendar
//
//  Created by nori on 2021/09/02.
//

import SwiftUI
import RecurrenceRulePicker

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

public struct Calendar<Data, Content>: View where Data: RandomAccessCollection, Data.Element: TimeRange, Data.Element: Hashable, Content: View {

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
        ForMonth(data) { date in
//            content(item)
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

    struct ContentView: View {

        @StateObject var store: Store = Store(displayMode: .week, today: Date())

        var body: some View {
            VStack {
                Picker("DisplayMode", selection: $store.displayMode.animation()) {
                    ForEach(CalendarDisplayMode.allCases, id: \.self) { displaymode in
                        Text(displaymode.text)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                Calendar([CalendarItem(id: "id", period: .allday(Date()))]) { date in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green)
                        .padding(1)
                        .overlay {
                            Text("\(date.id)")
                        }
                }
                .environmentObject(store)
            }
        }
    }

    static var previews: some View {
        ContentView()
    }
}
