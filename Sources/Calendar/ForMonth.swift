//
//  ForMonth.swift
//  ForMonth
//
//  Created by nori on 2021/09/08.
//

import SwiftUI

public struct ForMonth<Data, Content>: View where Data: RandomAccessCollection, Data.Element: TimeRange, Data.Element: Hashable, Content: View {

    @EnvironmentObject var store: Store

    var data: Data

    var content: (Data.Element) -> Content

    public init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
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
        let height = size.height / 6
        let width = size.width / 7
        return CGSize(width: width, height: height)
    }

    func cell(_ date: Date) -> some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text("\(date.day)")
                .background {
                    if store.calendar.isDateInToday(date) {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 32, height: 32)
                    }
                }
                .padding()
            Spacer()
            Divider()
        }
        .background(store.calendar.isDateInWeekend(date) ? Color(.systemGray6) : nil)
    }

    var header: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(Foundation.Calendar.current.shortWeekdaySymbols, id: \.self) { weekdaySymbol in
                VStack {
                    Text("\(weekdaySymbol)")
                }
            }
        }
    }

    public var body: some View {
        GeometryReader { proxy in
            VStack {
                header
                    .frame(width: proxy.size.width, height: 44)
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
                        .compositingGroup()
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


struct ForMonth_Previews: PreviewProvider {

    struct Item: Hashable, TimeRange {

        var range: Range<Date> { Date()..<Date().date(byAdding: .day, value: 1)}

        static func == (lhs: Item, rhs: Item) -> Bool {
            lhs.hashValue == rhs.hashValue
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(range)
        }
    }

    static var previews: some View {
        ForMonth([Item()]) { date in
            Rectangle()
        }
        .environmentObject(Store(today: Date()))
        .previewInterfaceOrientation(.landscapeLeft)
    }
}
