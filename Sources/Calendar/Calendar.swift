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

public struct Calendar<Content>: View where Content: View {

    @EnvironmentObject var store: Store

    var content: (Date) -> Content

    func columnsForYear(_ size: CGSize? = nil) -> [GridItem] {

        switch store.displayMode {
            case .year: return [
                GridItem(.flexible(), spacing: store.spacingForYear),
                GridItem(.flexible(), spacing: store.spacingForYear),
                GridItem(.flexible(), spacing: store.spacingForYear)
            ]
            case .month: return [
                GridItem(.flexible(), spacing: store.spacingForYear)
            ]
            case .week, .day: return [
                //                GridItem(.flexible(), spacing: store.spacingForYear),
                //                GridItem(.flexible(), spacing: store.spacingForYear),
                //                GridItem(.flexible(), spacing: store.spacingForYear),
                //                GridItem(.flexible(), spacing: store.spacingForYear),
                //                GridItem(.flexible(), spacing: store.spacingForYear),
                //                GridItem(.flexible(), spacing: store.spacingForYear),
                //                GridItem(.flexible(), spacing: store.spacingForYear),
                //                GridItem(.flexible(), spacing: store.spacingForYear),
                //                GridItem(.flexible(), spacing: store.spacingForYear),
                //                GridItem(.flexible(), spacing: store.spacingForYear),
                //                GridItem(.flexible(), spacing: store.spacingForYear),
                GridItem(.flexible(), spacing: store.spacingForYear)
            ]
        }
    }

    func columnsForMonth(_ size: CGSize? = nil) -> [GridItem] {
        if case .day = store.displayMode {
            return [
                GridItem(.flexible(), spacing: store.spacingForMonth)
            ]
        }
        return [
            GridItem(.flexible(), spacing: store.spacingForMonth),
            GridItem(.flexible(), spacing: store.spacingForMonth),
            GridItem(.flexible(), spacing: store.spacingForMonth),
            GridItem(.flexible(), spacing: store.spacingForMonth),
            GridItem(.flexible(), spacing: store.spacingForMonth),
            GridItem(.flexible(), spacing: store.spacingForMonth),
            GridItem(.flexible(), spacing: store.spacingForMonth)
        ]
    }

    public init(@ViewBuilder content: @escaping (Date) -> Content) {
        self.content = content
    }

    var header: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: store.spacingForMonth),
            GridItem(.flexible(), spacing: store.spacingForMonth),
            GridItem(.flexible(), spacing: store.spacingForMonth),
            GridItem(.flexible(), spacing: store.spacingForMonth),
            GridItem(.flexible(), spacing: store.spacingForMonth),
            GridItem(.flexible(), spacing: store.spacingForMonth),
            GridItem(.flexible(), spacing: store.spacingForMonth)
        ], spacing: store.spacingForMonth) {
            ForEach(Foundation.Calendar.current.shortWeekdaySymbols, id: \.self) { weekdaySymbol in
                VStack {
                    Text("\(weekdaySymbol)")
                }
            }
        }
    }

    var forYear: some View {
        ForYear(columns: [
            GridItem(.flexible(), spacing: 24),
            GridItem(.flexible(), spacing: 24),
            GridItem(.flexible(), spacing: 24)
        ]) { date in

        }
    }

    var forMonth: some View {
        ForMonth { date in
            Text("\(date.id)")
        }
    }

    var forWeek: some View {
        ForWeek { date in
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green)
                .padding(1)
                .overlay {
                    Text("\(date.id)")
                }
        }
    }

    var forDay: some View {
        ForDay { date in
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green)
                .padding(1)
                .overlay {
                    Text("\(date.id)")
                }
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
            .setItem(CalendarItem(id: "id", period: .allday(Date())))

        var height: CGFloat? {
            switch store.displayMode {
                case .year, .month: return store.size?.height
                default:
                    if let height = store.size?.height {
                        return height * 12
                    } else {
                        return nil
                    }
            }
        }

        var body: some View {
            VStack {
                Picker("DisplayMode", selection: $store.displayMode.animation()) {
                    ForEach(CalendarDisplayMode.allCases, id: \.self) { displaymode in
                        Text(displaymode.text)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                Calendar { date in
                    if store.selectedDate == date {
                        Circle()
                            .fill(Color.red)
                            .overlay {
                                Text("\(date.day)")
                            }
                    } else {
                        Text("\(date.day)")
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
