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
        if case .year = store.displayMode {
            return [
                GridItem(.flexible(), spacing: store.spacingForYear),
                GridItem(.flexible(), spacing: store.spacingForYear),
                GridItem(.flexible(), spacing: store.spacingForYear)
            ]
        }
        return [
            GridItem(.flexible(), spacing: store.spacingForYear)
        ]
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

    public var body: some View {
        ScrollViewReader { scrollViewProxy in
            ForYear(store.year, columns: columnsForYear(), spacing: store.spacingForYear) { month in
                ForMonth(month, year: store.year, columns: columnsForMonth(), spacing: store.spacingForMonth, calendar: store.calendar, timeZone: store.timeZone) { _ in
                    header
                } content: { date in
                    ForDay(date.day, month: month, year: store.year) { date in
                        content(date)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            self.store.selectedDate = date
                        }
                    }
                    .tag(date)
                    .onReceive(store.$selectedDate) { newValue in
                        scrollViewProxy.scrollTo(newValue)
                    }
                    .onReceive(store.$displayMode) { newValue in
                        scrollViewProxy.scrollTo(newValue)
                    }
                }
            }
            .compositingGroup()
        }
        .environmentObject(store)
    }
}

struct Calendar_Previews: PreviewProvider {

    struct ContentView: View {

        @StateObject var store: Store = Store(displayMode: .year, today: Date())

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
//                GeometryReader { proxy in
//                    ScrollView {
//
//                        .frame(height: height)
//                    }.background(GeometryReader { proxy in
//                        Rectangle().fill(Color.clear).onAppear { store.size = proxy.size }
//                    })
//                }
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
