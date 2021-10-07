//
//  ForYear.swift
//  ForYear
//
//  Created by nori on 2021/09/08.
//

import SwiftUI

public struct ForYear<Data, Content>: View where Data: RandomAccessCollection, Data.Element: CalendarItemRepresentable, Content: View {

#if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
#endif

    @EnvironmentObject var store: Store

    var data: Data

    var columns: [GridItem]

    var spacing: CGFloat

    var content: (Date) -> Content

    public init(_ data: Data, columns: [GridItem], spacing: CGFloat = 18, @ViewBuilder content: @escaping (Date) -> Content) {
        self.data = data
        self.spacing = spacing
        self.columns = columns
        self.content = content
    }

    func height(size: CGSize) -> CGFloat {
        let row = 12 / columns.count
        let space = spacing * CGFloat(row - 1)
        return (size.height - space) / CGFloat(row)
    }

    func foreground(month: Date, date: Date) -> Color? {
        if store.calendar.isDateInToday(date) && store.calendar.component(.month, from: month) == store.calendar.component(.month, from: date) {
            return Color.white
        }
        if store.calendar.component(.month, from: month) != store.calendar.component(.month, from: date) {
            return Color(.systemGray4)
        }
        if store.calendar.isDateInWeekend(date) {
            return Color(.systemGray)
        }
        return nil
    }

    @ViewBuilder
    var todayCircle: some View {
#if os(iOS)
        let size: CGFloat = horizontalSizeClass == .compact ? 20 : 32
        Circle()
            .fill(Color.accentColor)
            .frame(width: size, height: size)
#else
        Circle()
            .fill(Color.accentColor)
            .frame(width: 32, height: 32)
#endif
    }

    func forYear(year: Date, size: CGSize) -> some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(DateRange(year, range: 0..<12, component: .month)) { month in
                VStack(spacing: 0) {
                    HStack {
                        Text(month, formatter: store.monthFormatter)
#if os(iOS)
                            .font(horizontalSizeClass == .compact ? .headline : .title3)
#else
                            .font(.title2)
#endif
                            .foregroundColor(Color.accentColor)
                            .padding(.leading, 4)
                        Spacer()
                    }
                    Month(month) { date in
                        Text(date, formatter: store.dayFormatter)
#if os(iOS)
                            .font(horizontalSizeClass == .compact ? .caption2 : .body)
#endif
                            .foregroundColor(foreground(month: month, date: date))
                            .background {
                                if store.calendar.isDateInToday(date) && store.calendar.component(.month, from: month) == store.calendar.component(.month, from: date) {
                                    todayCircle
                                }
                            }
                            .id(date.dayTag)
                    }
                }
                    .frame(height: height(size: size))
            }
        }
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollViewReader { scrollViewProxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: spacing) {
                        ForEach(DateRange(store.displayedDate, range: -100..<100, component: .year)) { year in
                            forYear(year: year, size: proxy.size)
                                .id(year.yearTag)
                        }
                    }
                    .compositingGroup()
                    .onAppear {
                        scrollViewProxy.scrollTo(store.displayedDate.yearTag)
                    }
                }
            }
        }
    }
}


struct Month<Content>: View where Content: View {

#if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
#endif

    @EnvironmentObject var store: Store

    var month: Date

    var content: (Date) -> Content

    init(_ month: Date, @ViewBuilder content: @escaping (Date) -> Content) {
        self.month = month
        self.content = content
    }

    var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0)
        ]
    }

    func size(_ size: CGSize) -> CGSize {
        let height = size.height / 7
        let width = size.width / 7
        return CGSize(width: width, height: height)
    }

    func header(_ size: CGSize) -> some View {
        LazyVGrid(columns: columns, spacing: 0) {
#if os(iOS)
            let weekdaySymbols = horizontalSizeClass == .compact ? Foundation.Calendar.current.veryShortWeekdaySymbols : Foundation.Calendar.current.shortWeekdaySymbols
#else
            let weekdaySymbols = Foundation.Calendar.current.shortWeekdaySymbols
#endif
            ForEach(weekdaySymbols.indices, id: \.self) { index in
                VStack {
                    Text(weekdaySymbols[index])
                        .font(.caption2)
                }
            }

        }
        .frame(height: self.size(size).height)
    }

    var body: some View {
        GeometryReader { proxy in
            LazyVGrid(columns: columns, spacing: 0, pinnedViews: []) {
                Section {
                    ForEach(DateRange(store.calendar.dateComponents([.calendar, .timeZone, .yearForWeekOfYear, .weekOfYear], from: month).date!, range: 0..<42, component: .day)) { date in
                        let size = size(proxy.size)
                        content(date)
                            .frame(width: size.width, height: size.height)
                    }
                } header: {
                    header(proxy.size)
                }
            }
        }
        .compositingGroup()
    }
}

struct ForYear_Previews: PreviewProvider {

    static var previews: some View {
        ForYear([
            CalendarItem(id: "id", period: Date()..<(Date() + 1.hours))
        ], columns: [
            GridItem(.flexible(), spacing: 5),
            GridItem(.flexible(), spacing: 5),
            GridItem(.flexible(), spacing: 5)
        ]) { month in

        }
        .environmentObject(Store(today: Date()))
    }
}
