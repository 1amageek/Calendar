//
//  ForWeek.swift
//  ForWeek
//
//  Created by nori on 2021/09/08.
//

import SwiftUI
import PageView

public struct ForWeek<Data, Content>: View where Data: RandomAccessCollection, Data.Element: CalendarItemRepresentable, Content: View {

#if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
#endif

    @EnvironmentObject var store: Store

    @State var offset: CGPoint = .zero

    var data: Data

    var spacing: CGFloat

    var content: (Data.Element) -> Content

    public init(_ data: Data, spacing: CGFloat = 4, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.content = content
    }

    @ViewBuilder
    var todayCircle: some View {
#if os(iOS)
        let size: CGFloat = horizontalSizeClass == .compact ? 20 : 32
        Circle()
            .fill(Color.accentColor)
            .frame(width: size, height: size)
#else
        Circle()
            .fill(Color.accentColor)
            .frame(width: 32, height: 32)
#endif
    }

    func header(dateRange: DateRange) -> some View {
        return LazyVGrid(columns: dateRange.map { _ in GridItem(.flexible(), spacing: 0) }) {
            ForEach(dateRange) { date in
                HStack {
                    Text(date, formatter: store.dayLocalFormatter)
                        .font(.headline)
                        .fontWeight(.regular)
                        .foregroundColor(store.calendar.isDateInToday(date) ? .white : nil)
                        .background {
                            if store.calendar.isDateInToday(date) {
                                todayCircle
                            }
                        }
                    Text(date, formatter: store.weekdayFormatter)
                        .font(.headline)
                        .fontWeight(.regular)
                }
            }
        }
    }

    @ViewBuilder
    func timeline(dateRange: DateRange) -> some View {
        let range = dateRange.dateRange
        VStack {
            header(dateRange: dateRange)
                .frame(height: 44)
            Timeline(data, range: range, scrollViewOffset: $offset) { item in
                content(item)
            }.background(
                TimelineBackground(dateRange) { date in
                    HStack {
                        Spacer()
                        Divider()
                    }
                }
            )
        }
    }

    @State var selection: Date = Date()

    public var body: some View {
        HStack {
            Ruler(offset: offset)
                .padding(.top, 44)
            TabView(selection: $selection) {
                ForEach(DateRange(store.displayedDate, range: -100..<100, component: .weekOfYear)) { weekOfYear in
                    let dateRange = DateRange(weekOfYear, range: (0..<7), component: .day)
                    timeline(dateRange: dateRange)
                        .tag(weekOfYear.weekOfYearTag)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onAppear {
                selection = store.displayedDate
            }
        }
    }
}

struct ForWeek_Previews: PreviewProvider {

    static var previews: some View {
        ForWeek([
            CalendarItem(id: "id", period: Date()..<(Date() + 1.hours))
        ]) { date in
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green)
                .padding(1)                
        }
        .environmentObject(Store(today: Date()))
        .environment(\.timeZone, TimeZone.current)
    }
}
