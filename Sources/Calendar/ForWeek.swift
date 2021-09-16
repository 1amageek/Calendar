//
//  ForWeek.swift
//  ForWeek
//
//  Created by nori on 2021/09/08.
//

import SwiftUI
import PageView

public struct ForWeek<Data, Content>: View where Data: RandomAccessCollection, Data.Element: TimeRange, Data.Element: Hashable, Content: View {

    @EnvironmentObject var store: Store

    @State var offset: CGPoint = .zero

    var data: Data

    var spacing: CGFloat

    var content: (Data.Element) -> Content

    var dateFormatter: DateFormatter

    public init(_ data: Data, spacing: CGFloat = 4, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        self.dateFormatter = dateFormatter
        self.spacing = spacing
        self.content = content
    }

    func header(dateRange: DateRange) -> some View {
        LazyVGrid(columns: dateRange.map { _ in GridItem(.flexible(), spacing: 0) }) {
            ForEach(dateRange) { date in
                HStack {
                    if store.calendar.isDateInToday(date) {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 32, height: 32)
                            .overlay {
                                Text("\(date.day)")
                            }
                    } else {
                        Text("\(date.day)")
                    }

                    Text(date, formatter: dateFormatter)
                }
            }
        }
    }

    @ViewBuilder
    func timeline(dateRange: DateRange) -> some View {
        let range = dateRange.dateRange
        VStack {
            header(dateRange: dateRange)
                .frame(height: 44)
            Timeline(data, range: range, scrollViewOffset: $offset) { item in
                content(item)
            }.background(
                TimelineBackground(dateRange) { date in
                    HStack {
                        Spacer()
                        Divider()
                    }
                }
            )
        }
    }

    public var body: some View {
        HStack {

            GeometryReader { proxy in
                ScrollView(.vertical) {
                    TimelineRuler()
                        .frame(height: proxy.size.height)
                        .offset(y: offset.y)
                }
            }
            .frame(width: 100)
            .padding(.top, 44)

            PageView($store.displayedDate) {
                ForEach(DateRange(store.selectedDate, range: -100..<100, component: .weekOfYear)) { weekOfYear in
                    let dateRange = DateRange(weekOfYear, range: (0..<7), component: .day)
                    timeline(dateRange: dateRange)
                }
            }
        }
    }
}

struct ForWeek_Previews: PreviewProvider {

    struct Item: Hashable, TimeRange {

        var range: Range<Date> = Date()..<Date().date(byAdding: .day, value: 1)

        static func == (lhs: Item, rhs: Item) -> Bool {
            lhs.hashValue == rhs.hashValue
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(range)
        }
    }

    static var previews: some View {
        ForWeek([Item()]) { date in
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green)
                .padding(1)                
        }
        .environmentObject(Store(today: Date()))
    }
}
