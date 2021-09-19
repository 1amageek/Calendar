//
//  ForWeek.swift
//  ForWeek
//
//  Created by nori on 2021/09/08.
//

import SwiftUI
import PageView

public struct ForWeek<Data, Content>: View where Data: RandomAccessCollection, Data.Element: CalendarItemRepresentable, Content: View {

    @EnvironmentObject var store: Store

    @State var offset: CGPoint = .zero

    var data: Data

    var spacing: CGFloat

    var content: (Data.Element) -> Content

    public init(_ data: Data, spacing: CGFloat = 4, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.content = content
    }

    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = store.timeZone
        dateFormatter.dateFormat = "E"
        return dateFormatter
    }

    var dayFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = store.timeZone
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }

    func header(dateRange: DateRange) -> some View {
        return LazyVGrid(columns: dateRange.map { _ in GridItem(.flexible(), spacing: 0) }) {
            ForEach(dateRange) { date in
                HStack {
                    if store.calendar.isDateInToday(date) {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 32, height: 32)
                            .overlay {
                                Text(date, formatter: dayFormatter)
                            }
                    } else {
                        Text(date, formatter: dayFormatter)
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

    static var previews: some View {
        ForWeek([
            CalendarItem(id: "id", period: Date()..<Date().date(byAdding: .day, value: 1))
        ]) { date in
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green)
                .padding(1)                
        }
        .environmentObject(Store(today: Date()))
        .environment(\.timeZone, TimeZone.current)
    }
}
