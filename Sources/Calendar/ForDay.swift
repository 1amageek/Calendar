//
//  ForDay.swift
//  ForDay
//
//  Created by nori on 2021/09/08.
//

import SwiftUI

public struct ForDay<Content>: View where Content: View {

    @EnvironmentObject var store: Store

    var day: Int

    var month: Int

    var year: Int

    var content: (Date) -> Content

    public init(_ day: Int, month: Int, year: Int, @ViewBuilder content: @escaping (Date) -> Content) {
        self.day = day
        self.month = month
        self.year = year
        self.content = content
    }

    var date: Date {
        let dateComponents: DateComponents = DateComponents(calendar: store.calendar, timeZone: store.timeZone, year: year, month: month, day: day)
        return store.calendar.date(from: dateComponents)!
    }

    public var body: some View {
        ZStack {
            content(date)
        }
    }
}


struct ForDay_Previews: PreviewProvider {
    static var previews: some View {
        ForDay(1, month: 09, year: 2021) { date in
            Text("ww")
        }
    }
}
