//
//  ForYear.swift
//  ForYear
//
//  Created by nori on 2021/09/08.
//

import SwiftUI

public struct ForYear<Content>: View where Content: View {

    @EnvironmentObject var store: Store

    var columns: [GridItem]

    var spacing: CGFloat

    var content: (Date) -> Content

    public init(columns: [GridItem], spacing: CGFloat = 32, @ViewBuilder content: @escaping (Date) -> Content) {
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
        if month.month != date.month {
            return Color(.systemGray4)
        }
        if store.calendar.isDateInWeekend(date) {
            return Color(.systemGray)
        }
        return nil
    }

    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M月"
        return dateFormatter
    }


    func forYear(year: Date, size: CGSize) -> some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(DateRange(year, range: 0..<12, component: .month)) { month in
                VStack {
                    HStack {
                        Text(month, formatter: dateFormatter)
                            .font(.title2)
                            .foregroundColor(Color.accentColor)
                            .padding(.leading, 8)
                        Spacer()
                    }
                    Month(month) { date in
                        Text("\(date.day)")
                            .foregroundColor(foreground(month: month, date: date))
                            .background {
                                if store.calendar.isDateInToday(date) {
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 32, height: 32)
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
                        ForEach(DateRange(store.selectedDate, range: -100..<100, component: .year)) { year in
                            forYear(year: year, size: proxy.size)
                                .id(year.yearTag)
                        }
                    }
                    .compositingGroup()
                    .onAppear {
                        scrollViewProxy.scrollTo(store.selectedDate.firstDayOfTheYear.yearTag)
                    }
                }
            }
        }
    }
}


struct Month<Content>: View where Content: View {

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
            ForEach(Foundation.Calendar.current.shortWeekdaySymbols, id: \.self) { weekdaySymbol in
                VStack {
                    Text("\(weekdaySymbol)")
                }
            }
        }
        .frame(height: self.size(size).height)
    }

    var body: some View {
        GeometryReader { proxy in
            LazyVGrid(columns: columns, spacing: 0, pinnedViews: []) {
                Section {
                    ForEach(DateRange(month.firstDayOfTheWeek, range: 0..<42, component: .day)) { date in
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
        ForYear(columns: [
            GridItem(.flexible(), spacing: 24),
            GridItem(.flexible(), spacing: 24),
            GridItem(.flexible(), spacing: 24)
        ]) { month in

        }
        .environmentObject(Store(today: Date()))
    }
}
