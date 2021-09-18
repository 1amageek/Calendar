//
//  EventStore.swift
//  EventStore
//
//  Created by nori on 2021/09/17.
//

import Foundation

public final class EventStore {

    public static func calendarItems<Event>(_ events: [Event], range: Range<Date>) -> [CalendarItem] where Event: EventRepresentable, Event.ID == String {
        if events.isEmpty { return [] }
        return events.reduce(Array<CalendarItem>()) { prev, event in
            let calendarItems = calendarItems(event, range: range)
            return prev + calendarItems
        }
    }

    public static func calendarItems<Event>(_ event: Event, range: Range<Date>) -> [CalendarItem] where Event: EventRepresentable, Event.ID == String {

        let calendar = Foundation.Calendar(identifier: .gregorian)
        var calendarItems: [CalendarItem] = []

        for rule in event.recurrenceRules {
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

            let lowerBound = event.period.lowerBound
            let upperBound = event.period.upperBound
            let date = event.occurrenceDate
            let components = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
            let startDate = calendar.setTime(components: components, date: lowerBound)
            let endDate = calendar.setTime(components: components, date: upperBound)
            let calendarItem: CalendarItem = CalendarItem(id: event.id, title: event.title, isAllDay: event.isAllDay, period: startDate..<endDate, timeZone: event.timeZone)
            calendarItems.append(calendarItem)

            switch rule.frequency {
                case .daily:

                    var count: Int = 1
                    var date: Date!

                    repeat {
                        let interval: Int = rule.interval * count
                        date = calendar.date(byAdding: .day, value: interval, to: event.occurrenceDate)
                        let components = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
                        let startDate = calendar.setTime(components: components, date: lowerBound)
                        let endDate = calendar.setTime(components: components, date: upperBound)
                        let calendarItem: CalendarItem = CalendarItem(id: event.id, title: event.title, isAllDay: event.isAllDay, period: startDate..<endDate, timeZone: event.timeZone)
                        calendarItems.append(calendarItem)
                        count += 1
                    } while (shouldRepeat(date: date, count: count))


                case .weekly:

                    var week: Int = 0
                    var count: Int = 1
                    var date: Date!

                    repeat {
                        let interval: Int = rule.interval * week
                        if let daysOfTheWeek = rule.daysOfTheWeek, !daysOfTheWeek.isEmpty {
                            for day in daysOfTheWeek {
                                date = calendar.date(byAdding: .day, value: interval, to: event.occurrenceDate.firstDayOfTheWeek)
                                date = date.date(byAdding: .day, value: day.weekNumber)
                                let components = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
                                let startDate = calendar.setTime(components: components, date: lowerBound)
                                let endDate = calendar.setTime(components: components, date: upperBound)
                                let calendarItem: CalendarItem = CalendarItem(id: event.id, title: event.title, isAllDay: event.isAllDay, period: startDate..<endDate, timeZone: event.timeZone)
                                calendarItems.append(calendarItem)
                                count += 1
                            }
                        } else {
                            let interval: Int = rule.interval * count * 7
                            date = calendar.date(byAdding: .day, value: interval, to: event.occurrenceDate)
                            let components = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
                            let startDate = calendar.setTime(components: components, date: lowerBound)
                            let endDate = calendar.setTime(components: components, date: upperBound)
                            let calendarItem: CalendarItem = CalendarItem(id: event.id, title: event.title, isAllDay: event.isAllDay, period: startDate..<endDate, timeZone: event.timeZone)
                            calendarItems.append(calendarItem)
                            count += 1
                        }
                        week += 1
                    } while (shouldRepeat(date: date, count: count))

                case .monthly:

                    var month: Int = 0
                    var count: Int = 1
                    var date: Date!

                    repeat {
                        let interval: Int = rule.interval * month
                        if let daysOfTheMonth = rule.daysOfTheMonth, !daysOfTheMonth.isEmpty {
                            for day in daysOfTheMonth {
                                date = calendar.date(byAdding: .month, value: interval, to: event.occurrenceDate.firstDayOfTheMonth)
                                date = date.date(byAdding: .day, value: day)
                                let components = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
                                let startDate = calendar.setTime(components: components, date: lowerBound)
                                let endDate = calendar.setTime(components: components, date: upperBound)
                                let calendarItem: CalendarItem = CalendarItem(id: event.id, title: event.title, isAllDay: event.isAllDay, period: startDate..<endDate, timeZone: event.timeZone)
                                calendarItems.append(calendarItem)
                                count += 1
                            }
                        } else {
                            date = calendar.date(byAdding: .month, value: interval, to: event.occurrenceDate)
                            let components = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
                            let startDate = calendar.setTime(components: components, date: lowerBound)
                            let endDate = calendar.setTime(components: components, date: upperBound)
                            let calendarItem: CalendarItem = CalendarItem(id: event.id, title: event.title, isAllDay: event.isAllDay, period: startDate..<endDate, timeZone: event.timeZone)
                            calendarItems.append(calendarItem)
                            count += 1
                        }
                        month += 1
                    } while (shouldRepeat(date: date, count: count))

                case .yearly:

                    var year: Int = 0
                    var count: Int = 1
                    var date: Date!

                    repeat {
                        let interval: Int = rule.interval * year
                        if let daysOfTheYear = rule.daysOfTheYear, !daysOfTheYear.isEmpty {
                            for day in daysOfTheYear {
                                date = calendar.date(byAdding: .year, value: interval, to: event.occurrenceDate.firstDayOfTheYear)
                                date = date.date(byAdding: .day, value: day)
                                let components = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
                                let startDate = calendar.setTime(components: components, date: lowerBound)
                                let endDate = calendar.setTime(components: components, date: upperBound)
                                let calendarItem: CalendarItem = CalendarItem(id: event.id, title: event.title, isAllDay: event.isAllDay, period: startDate..<endDate, timeZone: event.timeZone)
                                calendarItems.append(calendarItem)
                                count += 1
                            }
                        } else {
                            date = calendar.date(byAdding: .year, value: interval, to: event.occurrenceDate)
                            let components = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
                            let startDate = calendar.setTime(components: components, date: lowerBound)
                            let endDate = calendar.setTime(components: components, date: upperBound)
                            let calendarItem: CalendarItem = CalendarItem(id: event.id, title: event.title, isAllDay: event.isAllDay, period: startDate..<endDate, timeZone: event.timeZone)
                            calendarItems.append(calendarItem)
                            count += 1
                        }
                        year += 1
                    } while (shouldRepeat(date: date, count: count))
            }
        }

        return calendarItems
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
