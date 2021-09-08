//
//  ForMonth.swift
//  ForMonth
//
//  Created by nori on 2021/09/08.
//

import SwiftUI

public struct ForMonth<Header, Content>: View where Header: View, Content: View {

    @EnvironmentObject var store: Store

    var month: Int

    var year: Int

    var columns: [GridItem]

    var spacing: CGFloat

    var calendar: Foundation.Calendar

    var timeZone: TimeZone

    var header: (Int) -> Header

    var content: (Date) -> Content

    var dateComponents: DateComponents

    public init(_ month: Int,
                year: Int,
                columns: [GridItem],
                spacing: CGFloat = 16,
                calendar: Foundation.Calendar = Foundation.Calendar.current,
                timeZone: TimeZone = TimeZone.current,
                @ViewBuilder header: @escaping (Int) -> Header,
                @ViewBuilder content: @escaping (Date) -> Content) {
        self.dateComponents = DateComponents(calendar: calendar, timeZone: timeZone, year: year, month: month)
        self.month = month
        self.year = year
        self.columns = columns
        self.spacing = spacing
        self.calendar = calendar
        self.timeZone = timeZone
        self.header = header
        self.content = content
    }

    var headerHeight: CGFloat = 38

    var firstWeekdayOfTheMonth: Int {
        let firstWeekdayOfTheMonth = calendar.component(.weekday, from: dateComponents.date!)
        return firstWeekdayOfTheMonth == 7 ? 0 : firstWeekdayOfTheMonth
    }

    func day(_ day: Int) -> Int {
        let date = calendar.date(byAdding: .day, value: day, to: dateComponents.date!)!
        return calendar.component(.day, from: date)
    }

    func month(_ day: Int) -> Int {
        let date = calendar.date(byAdding: .day, value: day, to: dateComponents.date!)!
        return calendar.component(.month, from: date)
    }

    func height(size: CGSize) -> CGFloat {
        switch store.displayMode {
            case .day: return size.height - headerHeight
            case .week: return size.height - headerHeight
            default: return (size.height - headerHeight) / 5
        }
    }

    func date(_ offset: Int) -> Date {
        return calendar.date(byAdding: .day, value: offset, to: dateComponents.date!)!
    }

    public var body: some View {
        GeometryReader { proxy in
            LazyVGrid(columns: columns, spacing: 0, pinnedViews: [.sectionHeaders]) {
                Section {
                    ForEach(0..<35) { index in
                        content(date(index - firstWeekdayOfTheMonth))
                            .frame(maxWidth: .infinity, minHeight: height(size: proxy.size))
                    }
                } header: {
                    header(year)
                }
            }
        }
    }
}

struct ForMonth_Previews: PreviewProvider {
    static var previews: some View {
        ForMonth(9, year: 2021, columns: [
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0)
        ]) { _ in
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
        } content: { date in
            ForDay(date.day, month: 9, year: 2021) { a in
                Text("\(date.day)")
            }
        }
        .environmentObject(Store(today: Date()))
    }
}
