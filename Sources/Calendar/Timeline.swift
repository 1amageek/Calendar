//
//  Timeline.swift
//  Timeline
//
//  Created by nori on 2021/09/05.
//

import SwiftUI

struct Timeline<Data, Content>: View where Data: RandomAccessCollection, Data.Element: TimeFrameRepresentable, Data.Element: Hashable, Content: View {

    @Binding var scrollViewOffset: CGPoint

    var data: Data

    var range: Range<Date>

    var columns: Int

    var scale: CGFloat

    var content: (Data.Element) -> Content

    var items: [Item]

    var columnMagnitude: Int

    init(_ data: Data, range: Range<Date>, scrollViewOffset: Binding<CGPoint> = .constant(.zero), columns: Int = 7, scale: CGFloat = 1.8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self._scrollViewOffset = scrollViewOffset
        self.data = data
        self.range = range
        self.columns = columns
        self.scale = scale
        self.content = content
        let columnMagnitude = (range.upperBound.time - range.lowerBound.time) / columns
        self.columnMagnitude = columnMagnitude
        let separations = (1...columns).map { column -> Date in
            let number = column * columnMagnitude + range.lowerBound.time
            return number.date
        }
        var items: [Item] = []
        self.data.forEach { dataItem in
            var item: Item = Item(element: dataItem)
            separations.forEach { number in
                if dataItem.period.contains(number) {
                    if let last = item.ranges.last {
                        item.ranges.append((last.upperBound..<number))
                    } else if dataItem.period.lowerBound < number {
                        item.ranges.append((dataItem.period.lowerBound..<number))
                    }
                } else if let last = item.ranges.last, last.upperBound < dataItem.period.upperBound {
                    item.ranges.append((last.upperBound..<dataItem.period.upperBound))
                }
            }
            if item.ranges.isEmpty {
                item.ranges.append(dataItem.period)
            }
            items.append(item)
        }
        self.items = items
    }

    func rect(range: Range<Date>, size: CGSize) -> CGRect {
        let lowerBound = range.lowerBound.time - self.range.lowerBound.time
        let column = lowerBound / columnMagnitude
        let width = size.width / CGFloat(columns)
        let height = CGFloat(range.upperBound.time - range.lowerBound.time) / CGFloat(columnMagnitude) * size.height * scale
        let x: CGFloat = width * CGFloat(column)
        let y: CGFloat = CGFloat(lowerBound - column * columnMagnitude) / CGFloat(columnMagnitude) * size.height * scale

        return CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
    }

    func position(frame: CGRect) -> CGPoint {
        return CGPoint(x: frame.origin.x + frame.width / 2,
                       y: frame.origin.y + frame.height / 2)
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                ZStack {
                    ForEach(items, id: \.self) { item in
                        ForEach(item.ranges, id: \.self) { range in
                            let frame = rect(range: range, size: proxy.size)
                            let position = position(frame: frame)
                            content(item.element)
                                .frame(width: frame.width, height: frame.height, alignment: .center)
                                .position(position)
                        }
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height * scale)
                .background(GeometryReader { proxy in
                    Rectangle().fill(Color.clear)
                        .onChange(of: proxy.frame(in: .named("timeline.scroll"))) { newValue in
                            let frame = proxy.frame(in: .named("timeline.scroll"))
                            self.scrollViewOffset = frame.origin
                        }
                })

            }
            .coordinateSpace(name: "timeline.scroll")
        }
    }
}

extension Timeline {
    struct Item: Hashable {
        var element: Data.Element
        var ranges: [Range<Date>] = []
    }
}

public struct TimelineRuler: View {

    var range: Range<Int>

    var scale: CGFloat

    public init(_ range: Range<Int> = 0..<25, scale: CGFloat = 1.8) {
        self.range = range
        self.scale = scale
    }

    func rect(index: Int, size: CGSize) -> CGRect {
        let index = index - range.lowerBound
        let magnitude = range.upperBound - range.lowerBound
        let width = size.width
        let height = size.height * scale / CGFloat(magnitude)
        let x: CGFloat = width / 2
        let y: CGFloat = height * CGFloat(index) + height / 2
        return CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(range) { index in
                    let frame = rect(index: index, size: proxy.size)
                    HStack {
                        Spacer()
                        Text("\(index):00")
                    }
                    .frame(width: frame.width, height: frame.height)
                    .position(frame.origin)
                }
            }
        }
        .compositingGroup()
    }
}

public struct TimelineBackground<Content>: View where Content: View {

    var dateRange: DateRange

    var content: (Date) -> Content

    init(_ dateRange: DateRange, @ViewBuilder content: @escaping (Date) -> Content) {
        self.dateRange = dateRange
        self.content = content
    }

    public var body: some View {
        GeometryReader { proxy in
            HStack {
                ForEach(dateRange) { date in
                    content(date)
                }
            }
        }
        .compositingGroup()
    }
}

struct Timeline_Previews: PreviewProvider {

    struct Item: TimeFrameRepresentable, Hashable {
        var id: String
        var period: Range<Date>
    }

    static var range: Range<Int> {
        let calenar = Foundation.Calendar.current
        return calenar.range(of: .weekOfMonth, in: .year, for: Date())!
    }

    static func date(weekOfYear: Int) -> Date {
        let calendar = Foundation.Calendar.current
        return calendar.date(byAdding: .weekOfYear, value: weekOfYear, to: calendar.firstDayOfTheYear(date: Date()))!
    }

    static var previews: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.fixed(proxy.size.height))]) {
                    ForEach(range) { weekOfYear in
                        Timeline([
                            Item(id: "0", period: (Date().date(weekOfYear: 0)..<Date().date(weekOfYear: 2))),
                        ]
                                 , range: Date().date(weekOfYear: weekOfYear)..<Date().date(weekOfYear: weekOfYear + 1), columns: 7) { index in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green)
                                .padding(1)
                                .overlay {
                                    Text("\(index.id)")
                                }
                        }
                                 .background(TimelineBackground(DateRange(Date(), range: (0..<7), component: .day)) { date in
                                     HStack {
                                         Spacer()
                                         Divider()
                                     }
                                 })
                                 .frame(width: proxy.size.width, height: proxy.size.height)
                    }
                }
                .compositingGroup()
            }
        }
    }
}
