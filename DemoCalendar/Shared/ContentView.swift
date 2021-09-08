//
//  ContentView.swift
//  Shared
//
//  Created by nori on 2021/09/08.
//

import SwiftUI
import Calendar


struct ContentView: View {

    @StateObject var store: Store = Store(displayMode: .year, today: Date())

    var body: some View {
        VStack {
            Picker("DisplayMode", selection: $store.displayMode.animation()) {
                ForEach(CalendarDisplayMode.allCases, id: \.self) { displaymode in
                    Text(displaymode.text)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            ScrollView {
                Calendar { date in
                    if store.selectedDate == date {
                        Circle()
                            .fill(Color.red)
                            .overlay {
                                Text("\(date.day)")
                            }
                    } else {
                        Text("\(date.day)")
                    }
                }
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
