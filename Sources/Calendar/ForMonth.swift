//
//  ForMonth.swift
//  ForMonth
//
//  Created by nori on 2021/09/08.
//

import SwiftUI

public struct ForMonth<Data, Content>: View where Data: RandomAccessCollection, Data.Element: CalendarItemRepresentable, Content: View {

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
        let height = (size.height - headerHeight) / 6
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
            let items = data.filter({ store.calendar.isDate($0.period.lowerBound, inSameDayAs: date) || store.calendar.isDate($0.period.upperBound, inSameDayAs: date) })
            VStack {
                ForEach(items, id: \.self) { item in
                    content(item)
                }
            }
            Spacer()
            Divider()
        }
        .background(store.calendar.isDateInWeekend(date) ? Color(.systemGray6) : nil)
    }

    var headerHeight: CGFloat = 44

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
            VStack(spacing: 0) {
                header
                    .frame(width: proxy.size.width, height: headerHeight)
                ScrollViewReader { scrollViewProxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(DateRange.weekOfYear(year: store.today.year)) { weekOfYear in
                                HStack(spacing: 0) {
                                    ForEach(DateRange(weekOfYear, range: 0..<7, component: .day)) { date in
                                        let size = size(proxy.size)
                                        cell(date)
                                            .frame(width: size.width, height: size.height)
                                    }
                                }
                                .id(weekOfYear.weekOfYearTag)
                            }
                        }
                        .compositingGroup()
                        .onAppear {
                            scrollViewProxy.scrollTo(store.displayedDate.weekOfYearTag)
                        }
                        .background(GeometryReader { backgroundProxy in
                            Rectangle()
                                .fill(Color.clear)
                                .onChange(of: backgroundProxy.frame(in: .named("forMonth.scroll"))) { newValue in
                                    let offsetY = -backgroundProxy.frame(in: .named("forMonth.scroll")).origin.y
                                    let height = proxy.size.height - headerHeight
                                    let cellHeight = height / 6
                                    let weekOfYear = Int(offsetY / cellHeight) + 1
                                    let date = store.today.firstDayOfTheYear.date(byAdding: .weekOfYear, value: weekOfYear)
                                    if store.displayedDate.month != date.month {
                                        store.displayedDate = date
                                    }
                                }
                        })
                    }
                    .coordinateSpace(name: "forMonth.scroll")
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}


struct ForMonth_Previews: PreviewProvider {

    struct Header: View {

        @EnvironmentObject var store: Store

        var body: some View {
            Text(store.headerTitle)
                .font(.largeTitle)
                .fontWeight(.black)
        }
    }

    static var previews: some View {
        VStack {
            HStack {
                Header()
                Spacer()
                Group {
                    Button {

                    } label: {
                        Image(systemName: "chevron.backward")
                    }

                    Button("Today") {

                    }

                    Button {

                    } label: {
                        Image(systemName: "chevron.forward")
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            ForMonth([
                CalendarItem(id: "id", period: Date()..<Date().date(byAdding: .day, value: 1))
            ]) { date in
                Rectangle()
                    .padding(4)
            }
        }

        .environmentObject(Store(displayMode: .month, today: Date()))
        .previewInterfaceOrientation(.landscapeLeft)
    }
}
