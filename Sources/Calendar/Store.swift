//
//  Store.swift
//  Store
//
//  Created by nori on 2021/09/03.
//

import Foundation
import CoreGraphics

public final class Store: ObservableObject {

    @Published public var displayMode: CalendarDisplayMode

    @Published public var selectedDate: Date

    @Published public var items: [CalendarItem] = []

    @Published public var spacingForYear: CGFloat = 24

    @Published public var spacingForMonth: CGFloat = 12

    @Published var size: CGSize?

    func items(_ range: Range<Date>) -> [CalendarItem] {
        return items.reduce(Array<CalendarItem>()) { prev, item in
            let items = [item] + repeatItems(item, range: range)
            return prev + items
        }
    }

    var today: Date

    var calendar: Foundation.Calendar

    var timeZone: TimeZone

    var year: Int {
        return self.calendar.dateComponents([.day], from: self.selectedDate).day!
    }

    public init(displayMode: CalendarDisplayMode = .year, today: Date, calendar: Foundation.Calendar = Foundation.Calendar(identifier: .gregorian), timeZone: TimeZone = TimeZone.current) {
        self.today = today
        self.calendar = calendar
        self.timeZone = timeZone
        self._displayMode = Published(initialValue: displayMode)
        self._selectedDate = Published(initialValue: today)
    }

    func setItem(_ item: CalendarItem) -> Self {
        self.items.append(item)
        return self
    }

    func repeatItems(_ item: CalendarItem, range: Range<Date>) -> [CalendarItem] {
        if item.recurrenceRules.isEmpty { return [] }
        var items: [CalendarItem] = []

        for rule in item.recurrenceRules {
            if case .endDate(let date) = rule.recurrenceEnd {
                if date < range.lowerBound { continue }
            }

            func shouldRepeat(date: Date, count: Int) -> Bool {
                if let end = rule.recurrenceEnd {
                    switch end {
                        case .occurrenceCount(let occurrenceCount): return count < occurrenceCount
                        case .endDate(let endDate): return date < endDate
                    }
                }
                return date < range.upperBound
            }

            switch rule.frequency {
                case .daily:

                    var count: Int = 1
                    var date: Date!

                    repeat {
                        let interval: Int = rule.interval * count
                        date = calendar.date(byAdding: .day, value: interval, to: item.occurrenceDate)
                        let components = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
                        switch item.period {
                            case .allday:
                                let repeatItem: CalendarItem = item.duplicate(period: .allday(date))
                                items.append(repeatItem)
                            case .byTime(let byTime):
                                let startDate = calendar.setTime(components: components, date: byTime.lowerBound)
                                let endDate = calendar.setTime(components: components, date: byTime.upperBound)
                                let repeatItem: CalendarItem = item.duplicate(period: .byTime((startDate..<endDate)))
                                items.append(repeatItem)
                        }
                        count += 1
                    } while (shouldRepeat(date: date, count: count))


                case .weekly:

                    var count: Int = 1
                    var date: Date!

                    repeat {
                        let interval: Int = rule.interval * 7 * count
                        date = calendar.date(byAdding: .day, value: interval, to: item.occurrenceDate)
                        let components = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
                        switch item.period {
                            case .allday:
                                let repeatItem: CalendarItem = item.duplicate(period: .allday(date))
                                items.append(repeatItem)
                            case .byTime(let byTime):
                                let startDate = calendar.setTime(components: components, date: byTime.lowerBound)
                                let endDate = calendar.setTime(components: components, date: byTime.upperBound)
                                let repeatItem: CalendarItem = item.duplicate(period: .byTime((startDate..<endDate)))
                                items.append(repeatItem)
                        }
                        count += 1
                    } while (shouldRepeat(date: date, count: count))

                case .monthly: break
                case .yearly: break
            }
        }

        return items
    }
}

extension Foundation.Calendar {
    func setTime(components: DateComponents, date: Date) -> Date {
        var components = components
        let hour = self.component(.hour, from: date)
        let minute = self.component(.minute, from: date)
        let second = self.component(.second, from: date)
        components.hour = hour
        components.minute = minute
        components.second = second
        return self.date(from: components)!
    }
}
