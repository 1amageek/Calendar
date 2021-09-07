//
//  WeekView.swift
//  WeekView
//
//  Created by nori on 2021/09/03.
//

import SwiftUI
import RecurrenceRulePicker

struct WeekView: View {

    @EnvironmentObject var store: Store

    var firstWeekdayOfTheMonth: Int

    var headerHeight: CGFloat = 38

    var range: Range<Date> { store.today.date(dayOfWeek: 0)..<store.today.date(dayOfWeek: 7) }

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

//    func header(size: CGSize) -> some View {
//        LazyVGrid(columns: lanes, spacing: 0) {
//            ForEach(store.calendar.weekdaySymbols, id: \.self) { weekdaySymbol in
//                VStack {
//                    Text("\(weekdaySymbol)")
//                }
//                .frame(maxWidth: .infinity, alignment: .trailing)
//            }
//        }
//        .frame(height: headerHeight)
//    }


    struct Item: TimeRange, Hashable {
        var id: String
        var range: Range<Date>
    }

    var body: some View {
        ZStack {
            Timeline(store.items(range), range: range, columns: 7) { index in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.green)
                    .padding(1)
                    .overlay {
                        Text("\(index.id)")
                    }
            }
            VStack {
                Text("\(store.items(range)[1].range.lowerBound)")
                    .font(.system(size: 30))
                Text("\(store.items(range)[1].range.upperBound)")
                    .font(.system(size: 30))
            }

        }

    }
}


struct WeekView_Previews: PreviewProvider {

    static var previews: some View {
        WeekView(firstWeekdayOfTheMonth: 3)
            .environmentObject(
                Store(today: Date())
                    .setItem(.init(id: "0", period: .allday(Date()), recurrenceRules: [
                        RecurrenceRule(frequency: .daily, interval: 1)
                    ]))
//                    .setItem(.init(id: "0",
//                                   occurrenceDate: Date(),
//                                   period: .byTime(Date().date(byAdding: .day, value: 1)..<Date().date(byAdding: .day, value: 2)),
//                                   recurrenceRules: [RecurrenceRule(frequency: .daily, interval: 1)])
                            )

    }
}
