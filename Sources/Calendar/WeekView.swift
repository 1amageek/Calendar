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

    var range: Range<Date> { store.today.date(dayOfWeek: 0)..<store.today.date(dayOfWeek: 7) }

    init() { }

    func day(_ day: Int) -> Int {
        let date = store.calendar.date(byAdding: .day, value: day, to: store.dateComponents.date!)!
        return store.calendar.component(.day, from: date)
    }

    func month(_ day: Int) -> Int {
        let date = store.calendar.date(byAdding: .day, value: day, to: store.dateComponents.date!)!
        return store.calendar.component(.month, from: date)
    }

    func header() -> some View {
        HStack(spacing: 0) {
            ForEach(store.calendar.weekdaySymbols, id: \.self) { weekdaySymbol in
                VStack {
                    Text("\(weekdaySymbol)")
                        .padding()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    struct Item: TimeRange, Hashable {
        var id: String
        var range: Range<Date>
    }

    var body: some View {
        Timeline(store.items(range), range: range, columns: 7) { index in
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green)
                .padding(1)
                .overlay {
                    Text("\(index.id)")
                }
        }
        .safeAreaInset(edge: .top) {
            header()
        }
    }
}


struct WeekView_Previews: PreviewProvider {

    static var previews: some View {
        WeekView()
            .environmentObject(
                Store(today: Date())
                    .setItem(.init(id: "0", period: .allday(Date()), recurrenceRules: [
                        RecurrenceRule(frequency: .daily, interval: 1)
                    ]))
        )

    }
}
