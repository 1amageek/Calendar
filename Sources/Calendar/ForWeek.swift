//
//  SwiftUIView.swift
//  SwiftUIView
//
//  Created by nori on 2021/09/08.
//

import SwiftUI

public struct ForWeek<Content>: View where Content: View {

    @EnvironmentObject var store: Store

    var month: Int

    var year: Int

    var calendar: Foundation.Calendar

    var timeZone: TimeZone

    var content: (Int) -> Content

    var dateComponents: DateComponents

    public init(_ month: Int, year: Int, calendar: Foundation.Calendar = Foundation.Calendar.current, timeZone: TimeZone = TimeZone.current, @ViewBuilder content: @escaping (Int) -> Content) {
        self.dateComponents = DateComponents(calendar: calendar, timeZone: timeZone, year: year, month: month)
        self.month = month
        self.year = year
        self.calendar = calendar
        self.timeZone = timeZone
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

    func header(size: CGSize) -> some View {
        LazyVGrid(columns: columns(size: size), spacing: 0) {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekdaySymbol in
                VStack {
                    Text("\(weekdaySymbol)")
                }
            }
        }
        .frame(height: headerHeight)
    }

    func columns(size: CGSize) -> [GridItem] {
        return calendar.weekdaySymbols.map({ _ in GridItem(.flexible(), spacing: 0, alignment: .center) })
    }

    public var body: some View {
        GeometryReader { proxy in
            LazyVGrid(columns: columns(size: proxy.size), spacing: 0, pinnedViews: [.sectionHeaders]) {
                Section {
                    ForEach(0..<35) { index in
                        content(day(index - firstWeekdayOfTheMonth))
                        .frame(maxWidth: .infinity, minHeight: (proxy.size.height - headerHeight) / 5)
                    }
                } header: {
                    header(size: proxy.size)
                }
            }
        }
    }
}

struct ForWeek_Previews: PreviewProvider {
    static var previews: some View {
        ForWeek(9, year: 2021) { day in
            ForDay(day, month: 9, year: 2021) { a in
                Text("\(day)")
            }
        }
    }
}
