//
//  EventStore.swift
//  EventStore
//
//  Created by nori on 2021/09/17.
//

import Foundation

public final class EventStore {

    public func calendarItems<Event>(_ events: [Event], range: Range<Date>) -> [CalendarItem] where Event: EventRepresentable, Event.ID == String {
        if events.isEmpty { return [] }
        return events.reduce(Array<CalendarItem>()) { prev, event in
            let calendarItems = calendarItems(event, range: range)
            return prev + calendarItems
        }
    }

    public func calendarItems<Event>(_ event: Event, range: Range<Date>) -> [CalendarItem] where Event: EventRepresentable, Event.ID == String {

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

            let calendarItem: CalendarItem = CalendarItem(id: event.id, title: "", isAllDay: event.isAllDay, period: event.period, timeZone: event.timeZone)
            calendarItems.append(calendarItem)

            switch rule.frequency {
                case .daily:

                    var count: Int = 1
                    var date: Date!

                    repeat {
                        let interval: Int = rule.interval * count
                        date = calendar.date(byAdding: .day, value: interval, to: event.occurrenceDate)
                        let components = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
                        let startDate = calendar.setTime(components: components, date: event.period.lowerBound)
                        let endDate = calendar.setTime(components: components, date: event.period.upperBound)
                        let calendarItem: CalendarItem = CalendarItem(id: event.id, title: "", isAllDay: event.isAllDay, period: startDate..<endDate, timeZone: event.timeZone)
                        calendarItems.append(calendarItem)
                        count += 1
                    } while (shouldRepeat(date: date, count: count))


                case .weekly:

                    var count: Int = 1
                    var date: Date!

                    repeat {
                        let interval: Int = rule.interval * 7 * count
                        date = calendar.date(byAdding: .day, value: interval, to: event.occurrenceDate)
                        let components = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
                        let startDate = calendar.setTime(components: components, date: event.period.lowerBound)
                        let endDate = calendar.setTime(components: components, date: event.period.upperBound)
                        let calendarItem: CalendarItem = CalendarItem(id: event.id, title: "", isAllDay: event.isAllDay, period: startDate..<endDate, timeZone: event.timeZone)
                        calendarItems.append(calendarItem)
                        count += 1
                    } while (shouldRepeat(date: date, count: count))

                case .monthly:

                    var count: Int = 1
                    var date: Date!

                    repeat {
                        let interval: Int = rule.interval * count
                        date = calendar.date(byAdding: .month, value: interval, to: event.occurrenceDate)
                        let components = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
                        let startDate = calendar.setTime(components: components, date: event.period.lowerBound)
                        let endDate = calendar.setTime(components: components, date: event.period.upperBound)
                        let calendarItem: CalendarItem = CalendarItem(id: event.id, title: "", isAllDay: event.isAllDay, period: startDate..<endDate, timeZone: event.timeZone)
                        calendarItems.append(calendarItem)
                        count += 1
                    } while (shouldRepeat(date: date, count: count))

                case .yearly:

                    var count: Int = 1
                    var date: Date!

                    repeat {
                        let interval: Int = rule.interval * count
                        date = calendar.date(byAdding: .year, value: interval, to: event.occurrenceDate)
                        let components = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
                        let startDate = calendar.setTime(components: components, date: event.period.lowerBound)
                        let endDate = calendar.setTime(components: components, date: event.period.upperBound)
                        let calendarItem: CalendarItem = CalendarItem(id: event.id, title: "", isAllDay: event.isAllDay, period: startDate..<endDate, timeZone: event.timeZone)
                        calendarItems.append(calendarItem)
                        count += 1
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
