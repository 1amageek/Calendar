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
        let height = size.height / 6
        let width = size.width / 7
        return CGSize(width: width, height: height)
    }

    func cell(_ date: Date) -> some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text("\(date.day)")
                .foregroundColor(date.month != store.selectedDate.month ? Color.secondary : nil)
                .background {
                    if store.calendar.isDateInToday(date) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 32, height: 32)
                    }
                }
                .padding()
            Spacer()
            Divider()
        }
        .background(store.calendar.isDateInWeekend(date) ? Color(.systemGray6) : nil)
    }


    public var body: some View {
        GeometryReader { proxy in
            VStack {
                header(0)
                    .frame(height: 44)
                ScrollViewReader { scrollViewProxy in
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 0, pinnedViews: [.sectionHeaders]) {
                            ForEach(DateRange(store.selectedDate.firstDayOfTheWeek, range: -700..<700, component: .day)) { date in
                                let size = size(proxy.size)
                                cell(date)
                                    .frame(width: size.width, height: size.height)
                                    .id(date.dayTag)
                            }
                        }
                        .onAppear {
                            scrollViewProxy.scrollTo(store.selectedDate.firstDayOfTheMonth.dayTag)
                        }
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

//struct ForMonthBackground<Content>: View where Content: View {
//
//    @EnvironmentObject var store: Store
//
//    var month: Date
//
//    var content: (Date) -> Content
//
//    init(_ month: Date, @ViewBuilder content: @escaping (Date) -> Content) {
//        self.month = month
//        self.content = content
//    }
//
//    var columns: [GridItem] {
//        [
//            GridItem(.flexible(), spacing: 0),
//            GridItem(.flexible(), spacing: 0),
//            GridItem(.flexible(), spacing: 0),
//            GridItem(.flexible(), spacing: 0),
//            GridItem(.flexible(), spacing: 0),
//            GridItem(.flexible(), spacing: 0),
//            GridItem(.flexible(), spacing: 0)
//        ]
//    }
//
//    func size(_ size: CGSize) -> CGSize {
//        let height = size.height / 6
//        let width = size.width / 7
//        return CGSize(width: width, height: height)
//    }
//
//    var body: some View {
//        GeometryReader { proxy in
//            LazyVGrid(columns: columns, spacing: 0, pinnedViews: [.sectionHeaders]) {
//                ForEach(DateRange(month.firstDayOfTheWeek, range: 0..<42, component: .day)) { date in
//                    let size = size(proxy.size)
//                    content(date)
//                        .frame(width: size.width, height: size.height)
//                }
//            }
//        }
//    }
//}

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
        .previewInterfaceOrientation(.landscapeLeft)
    }
}
