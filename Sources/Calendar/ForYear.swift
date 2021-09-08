//
//  ForYear.swift
//  ForYear
//
//  Created by nori on 2021/09/08.
//

import SwiftUI

public struct ForYear<Content>: View where Content: View {

    @EnvironmentObject var store: Store

    var year: Int

    var columns: [GridItem]

    var spacing: CGFloat

    var content: (Int) -> Content

    public init(_ year: Int, columns: [GridItem], spacing: CGFloat = 32, @ViewBuilder content: @escaping (Int) -> Content) {
        self.year = year
        self.spacing = spacing
        self.columns = columns
        self.content = content

    }

    func height(size: CGSize) -> CGFloat {
        if case .year = store.displayMode {
            let row = 12 / columns.count
            let space = spacing * CGFloat(row - 1)
            return (size.height - space) / CGFloat(row)
        }
        return size.height
    }

    public var body: some View {
        GeometryReader { proxy in
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(1...12, id: \.self) { month in
                    content(month)
                        .frame(height: height(size: proxy.size))
                }
            }
        }
    }
}

struct ForYear_Previews: PreviewProvider {
    static var previews: some View {
        ForYear(2021, columns: [
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0)
        ]) { month in
            ForMonth(9, year: 2021, columns: [
                GridItem(.flexible(), spacing: 0),
                GridItem(.flexible(), spacing: 0),
                GridItem(.flexible(), spacing: 0),
                GridItem(.flexible(), spacing: 0),
                GridItem(.flexible(), spacing: 0),
                GridItem(.flexible(), spacing: 0),
                GridItem(.flexible(), spacing: 0)
            ]) { _ in
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 0),
                    GridItem(.flexible(), spacing: 0),
                    GridItem(.flexible(), spacing: 0),
                    GridItem(.flexible(), spacing: 0),
                    GridItem(.flexible(), spacing: 0),
                    GridItem(.flexible(), spacing: 0),
                    GridItem(.flexible(), spacing: 0)
                ], spacing: 0) {
                    ForEach(Foundation.Calendar.current.shortWeekdaySymbols, id: \.self) { weekdaySymbol in
                        VStack {
                            Text("\(weekdaySymbol)")
                        }
                    }
                }
            } content: { date in
                ForDay(date.day, month: 9, year: 2021) { a in
                    Text("\(date.day)")
                }
            }
        }
        .environmentObject(Store(today: Date()))
    }
}
