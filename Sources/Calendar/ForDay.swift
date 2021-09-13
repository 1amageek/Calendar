//
//  ForDay.swift
//  ForDay
//
//  Created by nori on 2021/09/08.
//

import SwiftUI

public struct ForDay<Content>: View where Content: View {

    @EnvironmentObject var store: Store

    @State var offset: CGPoint = .zero

    var spacing: CGFloat

    var content: (CalendarItem) -> Content

    public init(spacing: CGFloat = 4, @ViewBuilder content: @escaping (CalendarItem) -> Content) {
        self.spacing = spacing
        self.content = content
    }

    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY年M月d日"
        return dateFormatter
    }

    var weekdayFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter
    }

    func header(dateRange: DateRange) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(store.selectedDate, formatter: dateFormatter)
                    .font(.largeTitle)
                    .bold()
                Text(store.selectedDate, formatter: weekdayFormatter)
                    .font(.largeTitle)
            }
            .padding()
            Spacer()
        }
    }

    @ViewBuilder
    func timeline(dateRange: DateRange) -> some View {
        let range = dateRange.dateRange
        Timeline(store.items(range), range: range, scrollViewOffset: $offset, columns: 1) { item in
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

    public var body: some View {
        let dateRange = DateRange(store.selectedDate, range: (0..<1), component: .day)
        VStack {
            header(dateRange: dateRange)
//                .frame(height: 44)
            HStack {
                GeometryReader { proxy in
                    ScrollView(.vertical) {
                        TimelineRuler()
                            .frame(height: proxy.size.height)
                            .offset(y: offset.y)
                    }
                }
                .frame(width: 100)

                GeometryReader { proxy in
                    timeline(dateRange: dateRange)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                }
            }
        }
    }
}


struct ForDay_Previews: PreviewProvider {
    static var previews: some View {
        ForDay { date in
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
