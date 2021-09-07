//
//  Timeline.swift
//  Timeline
//
//  Created by nori on 2021/09/05.
//

import SwiftUI

struct Timeline<Data, Content>: View where Data: RandomAccessCollection, Data.Element: TimeRange, Data.Element: Hashable, Content: View {

    var data: Data

    var columns: Int

    var range: Range<Date>

    var content: (Data.Element) -> Content

    var items: [Item]

    var columnMagnitude: Int

    init(_ data: Data, range: Range<Date>, columns: Int = 7, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.columns = columns
        self.range = range
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
                if dataItem.range.contains(number) {
                    if let last = item.ranges.last {
                        item.ranges.append((last.upperBound..<number))
                    } else if dataItem.range.lowerBound < number {
                        item.ranges.append((dataItem.range.lowerBound..<number))
                    }
                } else if let last = item.ranges.last, last.upperBound < dataItem.range.upperBound {
                    item.ranges.append((last.upperBound..<dataItem.range.upperBound))
                }
            }
            if item.ranges.isEmpty {
                item.ranges.append(dataItem.range)
            }
            items.append(item)
        }
        self.items = items
    }

    func rect(range: Range<Date>, size: CGSize) -> CGRect {
        let lowerBound = range.lowerBound.time - self.range.lowerBound.time
        let column = lowerBound / columnMagnitude
        let width = size.width / CGFloat(columns)
        let height = CGFloat(range.upperBound.time - range.lowerBound.time) / CGFloat(columnMagnitude) * size.height
        let x: CGFloat = width * CGFloat(column)
        let y: CGFloat = CGFloat(lowerBound - column * columnMagnitude) / CGFloat(columnMagnitude) * size.height

        return CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
    }

    func position(frame: CGRect) -> CGPoint {
        return CGPoint(x: frame.origin.x + frame.width / 2,
                       y: frame.origin.y + frame.height / 2)
    }

    var body: some View {
        GeometryReader { proxy in
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
        }
    }
}

extension Timeline {
    struct Item: Hashable {
        var element: Data.Element
        var ranges: [Range<Date>] = []
    }
}

protocol TimeRange {
    var range: Range<Date> { get }
}

struct Timeline_Previews: PreviewProvider {

    struct Item: TimeRange, Hashable {
        var id: String
        var range: Range<Date>
    }

    static var previews: some View {
        Timeline([
            Item(id: "0", range: (Date().date(dayOfWeek: 1)..<Date().date(dayOfWeek: 6))),
//            Item(id: "1", range: (Date().date(dayOfWeek: 2)..<Date().date(dayOfWeek: 3).date(byAdding: .hour, value: -5))),
//            Item(id: "2", range: (Date().date(dayOfWeek: 3)..<Date().date(dayOfWeek: 4).date(byAdding: .hour, value: 5))),
        ]
            , range: Date().date(dayOfWeek: 0)..<Date().date(dayOfWeek: 7), columns: 7) { index in
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green)
                .padding(1)
                .overlay {
                    Text("\(index.id)")
                }
        }
    }
}
