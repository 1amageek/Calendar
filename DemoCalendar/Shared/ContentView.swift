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
        return [CalendarItem(id: "id", isAllDay: false, period: Date()..<(Date() + 1.days))]
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
