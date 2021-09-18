//
//  ContentView.swift
//  Shared
//
//  Created by nori on 2021/09/08.
//

import SwiftUI
import Calendar
import RecurrenceRule

struct Event: EventRepresentable {

    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(period)
    }

    var id: String

    var occurrenceDate: Date

    var recurrenceRules: [RecurrenceRule] = [RecurrenceRule(frequency: .daily, interval: 1)]

    var title: String = ""

    var isAllDay: Bool = false

    var period: Range<Date> = Date()..<Date().date(byAdding: .day, value: 1)

    var timeZone: TimeZone = TimeZone.current
}

struct ContentView: View {

    @StateObject var store: Store = Store(displayMode: .month, today: Date())

    var event: Event {
        let hour = Int(24 * value)
        var dateComopnents = Foundation.Calendar.current.dateComponents(in: TimeZone.current, from: Date())
        dateComopnents.hour = hour
        let startDate = Foundation.Calendar.current.date(from: dateComopnents)!
        let period = startDate..<Date().date(byAdding: .day, value: 2)
        return Event(id: "id", occurrenceDate: Date(), period: period)
    }

    var calendarItems: [CalendarItem] {
        let hour = Int(24 * value)
        var dateComopnents = Foundation.Calendar.current.dateComponents(in: TimeZone.current, from: Date())
        dateComopnents.hour = hour
        let startDate = Foundation.Calendar.current.date(from: dateComopnents)!
        let period = startDate..<Date().date(byAdding: .day, value: 2)
        return [
            CalendarItem(id: "id", period: period)
        ]
    }

    @State var value: Float = 0

    var body: some View {
        VStack {
            Picker("DisplayMode", selection: $store.displayMode.animation()) {
                ForEach(CalendarDisplayMode.allCases, id: \.self) { displaymode in
                    Text(displaymode.text)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            Slider(value: $value)
            Calendar(calendarItems) { date in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.green)
                    .padding(1)
            }
            .environmentObject(store)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
