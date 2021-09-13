//
//  ForMonth.swift
//  ForMonth
//
//  Created by nori on 2021/09/08.
//

import SwiftUI

public struct ForMonth<Header, Content>: View where Header: View, Content: View {

    @EnvironmentObject var store: Store


    var spacing: CGFloat

    var header: (Int) -> Header

    var content: (CalendarItem) -> Content

    public init(spacing: CGFloat = 16,
                @ViewBuilder header: @escaping (Int) -> Header,
                @ViewBuilder content: @escaping (CalendarItem) -> Content) {
        self.spacing = spacing
        self.header = header
        self.content = content
    }

    var headerHeight: CGFloat = 38

    var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing)
        ]
    }

//    var firstWeekdayOfTheMonth: Int {
//        let firstWeekdayOfTheMonth = calendar.component(.weekday, from: dateComponents.date!)
//        return firstWeekdayOfTheMonth == 7 ? 0 : firstWeekdayOfTheMonth
//    }
//
//    func day(_ day: Int) -> Int {
//        let date = calendar.date(byAdding: .day, value: day, to: dateComponents.date!)!
//        return calendar.component(.day, from: date)
//    }
//
//    func month(_ day: Int) -> Int {
//        let date = calendar.date(byAdding: .day, value: day, to: dateComponents.date!)!
//        return calendar.component(.month, from: date)
//    }

    func height(size: CGSize) -> CGFloat {
        switch store.displayMode {
            case .day: return size.height - headerHeight
            case .week: return size.height - headerHeight
            default: return (size.height - headerHeight) / 5
        }
    }

    func width(size: CGSize) -> CGFloat {
        size.width / 7
    }

//    func date(_ offset: Int) -> Date {
//        return calendar.date(byAdding: .day, value: offset, to: dateComponents.date!)!
//    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVStack {
                    Section {
                        ForEach(DateRange(store.selectedDate, range: 0..<10, component: .month)) { month in
                            HStack {
                                Text("ww")
                            }
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .background(ForMonthBackground(month, spacing: spacing) { date in
                                Text("\(date.day)")
                            })
                        }
                    } header: {
                        header(0)
                    }
                }
            }
        }
    }
}

struct ForMonthBackground<Content>: View where Content: View {

    @EnvironmentObject var store: Store

    var month: Date

    var content: (Date) -> Content

    init(_ month: Date, spacing: CGFloat, @ViewBuilder content: @escaping (Date) -> Content) {
        self.month = month
        self.spacing = spacing
        self.content = content
    }

    var spacing: CGFloat

    var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing)
        ]
    }

    func size(_ size: CGSize) -> CGSize {
        let height = size.height / 6
        let width = size.width / 7
        return CGSize(width: width, height: height)
    }

    var body: some View {
        GeometryReader { proxy in
            LazyVGrid(columns: columns, spacing: spacing, pinnedViews: [.sectionHeaders]) {
                ForEach(DateRange(month.firstDayOfTheWeek, range: 0..<42, component: .day)) { date in
                    let size = size(proxy.size)
                    content(date)
                        .frame(width: size.width, height: size.height)
                }
            }
        }
    }
}

struct ForMonth_Previews: PreviewProvider {
    static var previews: some View {
        ForMonth { _ in
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
            Text("\(date.id)")
        }
        .environmentObject(Store(today: Date()))
    }
}
