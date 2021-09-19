//
//  ForDay.swift
//  ForDay
//
//  Created by nori on 2021/09/08.
//

import SwiftUI

public struct ForDay<Data, Content>: View where Data: RandomAccessCollection, Data.Element: CalendarItemRepresentable, Content: View {

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

    func header(dateRange: DateRange) -> some View {
        HStack {
            Text(store.displayedDate, formatter: store.weekdayFormatter)
                .font(.largeTitle)
            Spacer()
        }
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }

    @ViewBuilder
    func timeline(dateRange: DateRange) -> some View {
        let range = dateRange.dateRange
        Timeline(data, range: range, scrollViewOffset: $offset, columns: 1) { item in
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
        let dateRange = DateRange(store.displayedDate, range: (0..<1), component: .day)
        VStack {
            header(dateRange: dateRange)
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
        ForDay([
            CalendarItem(id: "id", period: Date()..<Date().date(byAdding: .day, value: 1))
        ]) { date in
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green)
                .padding(1)
                .overlay {
                    
                }
        }
        .environmentObject(Store(today: Date()))
    }
}
