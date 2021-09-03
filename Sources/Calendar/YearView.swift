//
//  YearView.swift
//  YearView
//
//  Created by nori on 2021/09/02.
//

import SwiftUI

struct YearView: View {

    @EnvironmentObject var store: Store

    var spacing: CGFloat

    init(spacing: CGFloat = 32) {
        self.spacing = spacing
    }

    func columns(size: CGSize) -> [GridItem] {
        return [
           GridItem(.flexible(), spacing: spacing),
           GridItem(.flexible(), spacing: spacing),
           GridItem(.flexible(), spacing: spacing)
       ]
    }

    func height(size: CGSize) -> CGFloat {
        let row = 12 / columns(size: size).count
        let space = spacing * CGFloat(row - 1)
        return (size.height - space) / CGFloat(row)
    }

    func firstWeekdayOfTheMonth(year: Int, month: Int) -> Int {
        let dateComponents = DateComponents(calendar: store.calendar, timeZone: store.timeZone, year: store.year, month: month)
        let firstWeekdayOfTheMonth = self.store.calendar.component(.weekday, from: dateComponents.date!)
        return firstWeekdayOfTheMonth
    }

    var body: some View {
        GeometryReader { proxy in
            LazyVGrid(columns: columns(size: proxy.size), spacing: spacing) {
                ForEach(1...12, id: \.self) { month in
                    YearView.MonthView(firstWeekdayOfTheMonth: firstWeekdayOfTheMonth(year: 2000, month: month))
                        .frame(height: height(size: proxy.size))
                }
            }
        }
    }
}

extension YearView {

    struct MonthView: View {

        @EnvironmentObject var store: Store

        var firstWeekdayOfTheMonth: Int

        var width: CGFloat = 38

        init(firstWeekdayOfTheMonth: Int) {
            self.firstWeekdayOfTheMonth = firstWeekdayOfTheMonth == 7 ? 0 : firstWeekdayOfTheMonth
        }

        func day(_ day: Int) -> Int {
            let date = store.calendar.date(byAdding: .day, value: day, to: store.dateComponents.date!)!
            return store.calendar.component(.day, from: date)
        }

        func month(_ day: Int) -> Int {
            let date = store.calendar.date(byAdding: .day, value: day, to: store.dateComponents.date!)!
            return store.calendar.component(.month, from: date)
        }

        func header(size: CGSize) -> some View {
            VStack(alignment: .leading) {
                Text(store.calendar.shortMonthSymbols[store.month  - 1])
                LazyVGrid(columns: columns(size: size), spacing: 0) {
                    ForEach(store.calendar.weekdaySymbols, id: \.self) { weekdaySymbol in
                        Rectangle()
                            .fill(Color.clear)
                            .overlay {
                                Text("\(weekdaySymbol)")
                            }
                    }
                }
            }
            .frame(height: size.height / 6)
        }

        func columns(size: CGSize) -> [GridItem] {
            let spacing = spacing(size: size)
            return store.calendar.weekdaySymbols.map({ _ in GridItem(.fixed(self.width), spacing: spacing, alignment: .center) })
        }

        func spacing(size: CGSize) -> CGFloat {
            let width = size.width - self.width * 7
            return width / 5
        }

        var body: some View {
            GeometryReader { proxy in
                LazyVGrid(columns: columns(size: proxy.size), spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section {
                        ForEach(0..<35) { index in
                            Rectangle()
                                .fill(Color.clear)
                                .overlay {
                                    Text("\(day(index - firstWeekdayOfTheMonth))")
                                        .foregroundColor(store.month == month(index - firstWeekdayOfTheMonth) ? Color(.label) : Color.secondary )
                                }
                                .frame(height: proxy.size.height * 4 / 5 / 5)
                        }
                    } header: {
                        header(size: proxy.size)
                    }
                }

            }
        }
    }

}

struct YearView_Previews: PreviewProvider {
    static var previews: some View {
        YearView()
            .padding(32)
            .environmentObject(Store(today: Date()))
    }
}
