//
//  ForMonth.swift
//  ForMonth
//
//  Created by nori on 2021/09/08.
//

import SwiftUI

public struct ForMonth<Data, Content>: View where Data: RandomAccessCollection, Data.Element: CalendarItemRepresentable, Content: View {

    @EnvironmentObject var store: Store

#if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
#endif

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

    var dayFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = store.timeZone
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }

    func foreground(month: Date, date: Date) -> Color? {
        if store.calendar.isDateInToday(date) && store.calendar.component(.month, from: month) == store.calendar.component(.month, from: date) {
            return Color.white
        }
        if store.calendar.component(.month, from: month) != store.calendar.component(.month, from: date) {
#if os(iOS)
            return Color(.systemGray4)
#else
            return Color(.systemGray)
#endif
        }
        if store.calendar.isDateInWeekend(date) {
            return Color(.systemGray)
        }
        return nil
    }

    func size(_ size: CGSize) -> CGSize {
        let height = (size.height - headerHeight) / 6
        let width = size.width / 7
        return CGSize(width: width, height: height)
    }

    var cellAlignment: HorizontalAlignment {
#if os(iOS)
        return horizontalSizeClass == .compact ? .center : .leading
#else
        return .leading
#endif
    }

    func cell(_ date: Date) -> some View {
        VStack(alignment: cellAlignment, spacing: 0) {
            Text(date, formatter: store.dayFormatter)
                .foregroundColor(foreground(month: store.displayedDate, date: date))
                .background {
                    if store.calendar.isDateInToday(date) {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 32, height: 32)
                    }
                }

            #if os(iOS)
                .padding(.all, horizontalSizeClass == .compact ? 8 : nil)
            #else
                .padding()
            #endif

            let items = data.filter({ store.calendar.isDate($0.startDate, inSameDayAs: date) || store.calendar.isDate($0.endDate, inSameDayAs: date) })
            VStack(spacing: 1) {
                ForEach(items.prefix(4), id: \.self) { item in
                    content(item)
                }
                if items.count > 4 {
                    Text("+ \(items.count - 4)")
                }
            }
            Spacer()
            Divider()
        }
        .background(store.calendar.isDateInWeekend(date) ? Color(.systemGray).opacity(0.08) : nil)
    }

    var headerHeight: CGFloat = 44

    var header: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(Foundation.Calendar.current.shortWeekdaySymbols, id: \.self) { weekdaySymbol in
                VStack {
                    Text("\(weekdaySymbol)")
                        .font(.headline)
                        .fontWeight(.regular)
                }
            }
        }
    }

    var monthRange: DateRange { DateRange(store.today, range: -100..<100, component: .weekOfYear) }

    public var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                header
                    .frame(width: proxy.size.width, height: headerHeight)
                ScrollViewReader { scrollViewProxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(monthRange) { weekOfYear in
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
                            store.forMonthScrollToTodayAction = {
                                scrollViewProxy.scrollTo(store.today.weekOfYearTag)
                            }
                        }
                        .background(GeometryReader { backgroundProxy in
                            Rectangle()
                                .fill(Color.clear)
                                .onChange(of: backgroundProxy.frame(in: .named("forMonth.scroll"))) { newValue in
                                    let offsetY = -backgroundProxy.frame(in: .named("forMonth.scroll")).origin.y
                                    let height = proxy.size.height - headerHeight
                                    let cellHeight = height / 6
                                    let weekOfYear = Int(offsetY / cellHeight) + 2
                                    DispatchQueue.main.async {
                                        let date = store.calendar.dateComponents([.calendar, .timeZone, .yearForWeekOfYear, .weekOfYear], from: monthRange.lowerBound).date! + weekOfYear.weeks
                                        if store.calendar.component(.month, from: store.displayedDate) != store.calendar.component(.month, from: date) {
                                            store.displayedDate = date
                                        }
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
                .font(.title)
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
                CalendarItem(id: "id", startDate: Date(), endDate: (Date() + 1.hours))
            ]) { date in
                Rectangle()
                    .padding(4)
            }
        }

        .environmentObject(Store(displayMode: .month, today: Date()))
    }
}
