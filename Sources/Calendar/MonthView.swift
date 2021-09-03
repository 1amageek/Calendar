//
//  MonthView.swift
//  MonthView
//
//  Created by nori on 2021/09/02.
//

import SwiftUI

struct MonthView: View {

    @EnvironmentObject var store: Store

    var firstWeekdayOfTheMonth: Int

    var headerHeight: CGFloat = 38

    init(firstWeekdayOfTheMonth: Int) {
        self.firstWeekdayOfTheMonth = firstWeekdayOfTheMonth == 7 ? 0 : firstWeekdayOfTheMonth
    }
    
    func day(_ day: Int) -> Int {
        let date = store.calendar.date(byAdding: .day, value: day, to: store.dateComponents.date!)!
        return store.calendar.component(.day, from: date)
    }

    func month(_ day: Int) -> Int {
        let date = store.calendar.date(byAdding: .day, value: day, to: store.dateComponents.date!)!
        return store.calendar.component(.month, from: date)
    }

    func header(size: CGSize) -> some View {
        LazyVGrid(columns: columns(size: size), spacing: 0) {
            ForEach(store.calendar.weekdaySymbols, id: \.self) { weekdaySymbol in
                VStack {
                    Text("\(weekdaySymbol)")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .frame(height: headerHeight)
    }

    func columns(size: CGSize) -> [GridItem] {
        return store.calendar.weekdaySymbols.map({ _ in GridItem(.flexible(), spacing: 0, alignment: .center) })
    }

    var body: some View {
        GeometryReader { proxy in
//            ScrollView {
                LazyVGrid(columns: columns(size: proxy.size), spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section {
                        ForEach(0..<35) { index in
                            VStack {
                                Text("\(day(index - firstWeekdayOfTheMonth))")
                                    .foregroundColor(store.month == month(index - firstWeekdayOfTheMonth) ? Color(.label) : Color.secondary )
                            }
                            .frame(maxWidth: .infinity, minHeight: (proxy.size.height - headerHeight) / 5, alignment: .topTrailing)
                            .border(Color(.opaqueSeparator), width: 0.5)
                        }
                    } header: {
                        header(size: proxy.size)
                    }
                }
//            }
        }
    }
}

struct MonthView_Previews: PreviewProvider {
    static var previews: some View {
        MonthView(firstWeekdayOfTheMonth: 3)
            .environmentObject(Store(today: Date()))
    }
}
