//
//  ForWeek.swift
//  ForWeek
//
//  Created by nori on 2021/09/08.
//

import SwiftUI

public struct ForWeek<Content>: View where Content: View {

    @EnvironmentObject var store: Store

    @State var offset: CGPoint = .zero

    var spacing: CGFloat

    var content: (CalendarItem) -> Content

    var dateFormatter: DateFormatter

    public init(spacing: CGFloat = 4, @ViewBuilder content: @escaping (CalendarItem) -> Content) {
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
            Timeline(store.items(range), range: range, scrollViewOffset: $offset) { item in
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

            GeometryReader { proxy in
                ScrollViewReader { scrollViewProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: [GridItem(.fixed(proxy.size.height))]) {
                            ForEach(DateRange(store.selectedDate, range: -100..<100, component: .weekOfYear)) { weekOfYear in
                                let dateRange = DateRange(weekOfYear, range: (0..<7), component: .day)
                                timeline(dateRange: dateRange)
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .id(weekOfYear.weekOfYearTag)
                            }
                        }
                        .compositingGroup()
                    }
                    .onAppear {
                        scrollViewProxy.scrollTo(store.selectedDate.weekOfYearTag)
                    }
                }
            }
        }
    }
}

struct ForWeek_Previews: PreviewProvider {
    static var previews: some View {
        ForWeek() { date in
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green)
                .padding(1)
                .overlay {
                    Text("\(date.id)")
                }
        }
        .environmentObject(
            Store(displayMode: .week, today: Date())
                .setItem(CalendarItem(id: "id", period: .allday(Date())))
        )
    }
}
