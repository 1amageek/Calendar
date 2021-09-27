//
//  ContentView.swift
//  Shared
//
//  Created by nori on 2021/09/08.
//

import SwiftUI
import Calendar
import RecurrenceRule
import SwiftDate

struct Event: CalendarItemRepresentable {

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

    var timeZone: TimeZone? = TimeZone.current
}

struct ContentView: View {

    @StateObject var store: Store = Store(displayMode: .month, today: Date())

    var event: Event {
        var dateComopnents = Foundation.Calendar.current.dateComponents(in: TimeZone.current, from: Date())
        dateComopnents.hour = 9
        let startDate = Foundation.Calendar.current.date(from: dateComopnents)!
        let period = startDate..<(startDate + 3.hours)
        return Event(id: "id", occurrenceDate: Date(), recurrenceRules: [
            RecurrenceRule(frequency: .weekly, recurrenceEnd: .occurrenceCount(7), interval: 1, daysOfTheWeek: [.init(dayOfTheWeek: .monday), .init(dayOfTheWeek: .tuesday)])
        ], period: period)
    }

    var calendarItems: [CalendarItem] {
        return RecurrenceScheduler.calendarItems(event, range: store.displayedRange)
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
            HStack {
                Text(store.headerTitle)
                    .font(.largeTitle)
                    .fontWeight(.black)
                Spacer()

                Group {
                    Button {

                    } label: {
                        Image(systemName: "chevron.backward")
                    }

                    Button("Today") {

                    }

                    Button {

                    } label: {
                        Image(systemName: "chevron.forward")
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
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
