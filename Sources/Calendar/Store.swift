//
//  Store.swift
//  Store
//
//  Created by nori on 2021/09/03.
//

import Foundation


final class Store: ObservableObject {

    @Published var year: Int

    @Published var month: Int

    @Published var day: Int

    @Published var items: [Calendar.Item] = []

    func items(_ range: Range<Date>) -> [Calendar.Item] {
        return items.reduce(Array<Calendar.Item>()) { prev, item in
            let items = [item] + repeatItems(item, range: range)
            return prev + items
        }
    }

    var today: Date

    var calendar: Foundation.Calendar

    var timeZone: TimeZone

    var dateComponents: DateComponents

    init(today: Date, calendar: Foundation.Calendar = Foundation.Calendar(identifier: .gregorian), timeZone: TimeZone = TimeZone.current) {
        self.today = today
        self.calendar = calendar
        self.timeZone = timeZone
        let year: Int = calendar.component(.year, from: today)
        let month: Int = calendar.component(.month, from: today)
        let day: Int = calendar.component(.day, from: today)
        self._year = Published(initialValue: year)
        self._month = Published(initialValue: month)
        self._day = Published(initialValue: day)
        self.dateComponents = DateComponents(calendar: calendar, timeZone: timeZone, year: year, month: month, day: day)
    }

    var firstWeekdayOfTheMonth: Int {
        let dateComponents = DateComponents(calendar: calendar, timeZone: timeZone, year: year, month: month)
        let firstWeekdayOfTheMonth = calendar.component(.weekday, from: dateComponents.date!)
        return firstWeekdayOfTheMonth
    }

    func setItem(_ item: Calendar.Item) -> Self {
        self.items.append(item)
        return self
    }

    func repeatItems(_ item: Calendar.Item, range: Range<Date>) -> [Calendar.Item] {
        if item.recurrenceRules.isEmpty { return [] }
        var items: [Calendar.Item] = []

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
                                let repeatItem: Calendar.Item = item.duplicate(period: .allday(date))
                                items.append(repeatItem)
                            case .byTime(let byTime):
                                let startDate = calendar.setTime(components: components, date: byTime.lowerBound)
                                let endDate = calendar.setTime(components: components, date: byTime.upperBound)
                                let repeatItem: Calendar.Item = item.duplicate(period: .byTime((startDate..<endDate)))
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
                                let repeatItem: Calendar.Item = item.duplicate(period: .allday(date))
                                items.append(repeatItem)
                            case .byTime(let byTime):
                                let startDate = calendar.setTime(components: components, date: byTime.lowerBound)
                                let endDate = calendar.setTime(components: components, date: byTime.upperBound)
                                let repeatItem: Calendar.Item = item.duplicate(period: .byTime((startDate..<endDate)))
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
