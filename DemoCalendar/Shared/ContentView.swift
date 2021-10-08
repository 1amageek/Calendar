//
//  ContentView.swift
//  Shared
//
//  Created by nori on 2021/09/08.
//

import SwiftUI
import Calendar
import RecurrenceRule

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

    var period: Range<Date> = Date()..<(Date() + 1.days)

    var timeZone: TimeZone? = TimeZone.current
}

struct ContentView: View {

    @StateObject var store: Store = Store(displayMode: .month, today: Date())

    var calendarItems: [CalendarItem] {
        let dateComopnents = store.calendar.dateComponents(in: TimeZone.current, from: Date())
        let startDate = store.calendar.date(from: dateComopnents)! - 12.hours
        return [
            CalendarItem(id: "0", isAllDay: false, period: startDate..<(startDate + 1.hours)),
            CalendarItem(id: "1", isAllDay: false, period: (startDate + 4.hours)..<(startDate + 5.hours)),
            CalendarItem(id: "2", isAllDay: false, period: (startDate + 6.hours)..<(startDate + 7.hours)),
            CalendarItem(id: "3", isAllDay: false, period: (startDate + 8.hours)..<(startDate + 9.hours)),
        ]
    }

    @State var value: Float = 0

    func action(item: CalendarItem) {
        switch store.displayMode {

            case .day, .week: break

            case .month:
                withAnimation {
                    store.displayMode = .week
                    store.displayedDate = item.period.lowerBound
                }
            case .year:
                withAnimation {
                    store.displayMode = .month
                    store.displayedDate = item.period.lowerBound
                }
        }
    }

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
                        store.scrollToToday()
                    }

                    Button {

                    } label: {
                        Image(systemName: "chevron.forward")
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            Calendar(calendarItems) { item in
                Button {
                    action(item: item)
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green)
                        .padding(1)
                }
            }
            .environmentObject(store)
            .onAppear {
                print(calendarItems)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
