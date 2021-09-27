//
//  RecurrenceScheduler.swift
//  
//
//  Created by nori on 2021/09/18.
//

import Foundation
import SwiftDate
import RecurrenceRule

public final class RecurrenceScheduler {

    public static func calendarItems<Item>(_ events: [Item], range: Range<Date>) -> [CalendarItem] where Item: Recurrenceable & CalendarItemRepresentable, Item.ID == String {
        if events.isEmpty { return [] }
        return events.reduce(Array<CalendarItem>()) { prev, event in
            let calendarItems = calendarItems(event, range: range)
            return prev + calendarItems
        }
    }

    public static func calendarItems<Item>(_ item: Item, range: Range<Date>) -> [CalendarItem] where Item: Recurrenceable & CalendarItemRepresentable, Item.ID == String {

        if item.recurrenceRules.isEmpty {
            return []
        }

        let calendar = Foundation.Calendar(identifier: .gregorian)
        var calendarItems: [CalendarItem] = []

        for rule in item.recurrenceRules {
            if rule.interval == 0 { continue }
            if range.upperBound < item.occurrenceDate { continue }

            var lowerBound = range.lowerBound
            var upperBound = range.upperBound

            let occurrenceDate: Date = item.occurrenceDate

            if range.lowerBound < occurrenceDate {
                lowerBound = occurrenceDate
            }

            if case .endDate(let date) = rule.recurrenceEnd {
                if date < range.lowerBound { continue }
                if range.upperBound < date {
                    upperBound = range.upperBound
                }
            }

            func frequencyCountAndRemainder(frequency: RecurrenceRule.Frequency, from: Date, to: Date, interval: Int) -> (Int, Int) {
                var difference: Int = 0
                let calendar: Foundation.Calendar = Foundation.Calendar(identifier: .gregorian)
                switch frequency {
                    case .daily: difference = calendar.dateComponents([.day], from: from.dateAtStartOf(.day), to: to.dateAtStartOf(.day)).day!
                    case .weekly: difference = calendar.dateComponents([.weekOfYear], from: from.dateAtStartOf(.weekOfYear), to: to.dateAtStartOf(.weekOfYear)).weekOfYear!
                    case .monthly: difference = calendar.dateComponents([.month], from: from.dateAtStartOf(.month), to: to.dateAtStartOf(.month)).month!
                    case .yearly: difference = calendar.dateComponents([.year], from: from.dateAtStartOf(.year), to: to.dateAtStartOf(.year)).year!
                }
                return difference.quotientAndRemainder(dividingBy: interval)
            }

            func setTime(dateComponents: DateComponents, date: Date) -> Date {
                var dateComponents = dateComponents
                dateComponents.hour = date.hour
                dateComponents.minute = date.minute
                dateComponents.second = date.second
                return dateComponents.date!
            }

            func makeCalendarItem(date: Date, range: Range<Date>) -> CalendarItem? {
                let dateComponents = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
                let startDate = setTime(dateComponents: dateComponents, date: item.period.lowerBound)
                let endDate = setTime(dateComponents: dateComponents, date: item.period.upperBound)
                guard startDate > range.lowerBound else { return nil }
                guard startDate < range.upperBound else { return nil }
                return CalendarItem(id: item.id, isAllDay: item.isAllDay, period: startDate..<endDate, timeZone: item.timeZone)
            }

            switch rule.frequency {
                case .daily:
                    let bundle: Int = 1
                    let (currentRepeatFrequencyCount, remainder) = frequencyCountAndRemainder(frequency: rule.frequency, from: occurrenceDate, to: lowerBound, interval: rule.interval)
                    let occurredCount = currentRepeatFrequencyCount * bundle
                    if case .occurrenceCount(let occurrenceCount) = rule.recurrenceEnd {
                        if occurrenceCount < occurredCount {
                            continue
                        }
                    }
                    let (repeatFrequencyCount, _) = frequencyCountAndRemainder(frequency: rule.frequency, from: (occurrenceDate - remainder.days), to: upperBound, interval: rule.interval)
                    var numberOfFrequencyRemaining: Int = repeatFrequencyCount
                    if case .occurrenceCount(let occurrenceCount) = rule.recurrenceEnd {
                        let numberOfOccurrencesRemaining = occurrenceCount - occurredCount
                        numberOfFrequencyRemaining = numberOfOccurrencesRemaining / bundle
                    }
                    (currentRepeatFrequencyCount...numberOfFrequencyRemaining).forEach { index in
                        let interval: Int = rule.interval * index
                        let date = occurrenceDate + interval.days
                        if let calendarItem = makeCalendarItem(date: date, range: lowerBound..<upperBound) {
                            calendarItems.append(calendarItem)
                        }
                    }
                case .weekly:
                    let bundle: Int = rule.daysOfTheWeek!.count
                    let (currentRepeatFrequencyCount, remainder) = frequencyCountAndRemainder(frequency: rule.frequency, from: occurrenceDate, to: lowerBound, interval: rule.interval)
                    let occurredCount = currentRepeatFrequencyCount * bundle
                    if case .occurrenceCount(let occurrenceCount) = rule.recurrenceEnd {
                        if occurrenceCount < occurredCount {
                            continue
                        }
                    }
                    let (repeatFrequencyCount, _) = frequencyCountAndRemainder(frequency: rule.frequency, from: (occurrenceDate - remainder.weeks), to: upperBound, interval: rule.interval)
                    var numberOfFrequencyRemaining: Int = repeatFrequencyCount
                    var numberOfCountRemaining: Int = 0
                    if case .occurrenceCount(let occurrenceCount) = rule.recurrenceEnd {
                        let numberOfOccurrencesRemaining = occurrenceCount - occurredCount
                        (numberOfFrequencyRemaining, numberOfCountRemaining) = numberOfOccurrencesRemaining.quotientAndRemainder(dividingBy: bundle)
                    }
                    (currentRepeatFrequencyCount...numberOfFrequencyRemaining).forEach { index in
                        for day in rule.daysOfTheWeek! {
                            let interval: Int = rule.interval * index
                            let date = occurrenceDate + interval.weeks + day.dayOfTheWeek.rawValue.days
                            if let calendarItem = makeCalendarItem(date: date, range: lowerBound..<upperBound) {
                                calendarItems.append(calendarItem)
                            }
                        }
                    }
                    (0..<numberOfCountRemaining).forEach { index in
                        let dayOfWeek = rule.daysOfTheWeek![index]
                        let interval: Int = numberOfFrequencyRemaining + 1
                        let date = occurrenceDate + interval.weeks + dayOfWeek.dayOfTheWeek.rawValue.days
                        if let calendarItem = makeCalendarItem(date: date, range: lowerBound..<upperBound) {
                            calendarItems.append(calendarItem)
                        }
                    }
                case .monthly:
                    if let daysOfTheWeek = rule.daysOfTheWeek {
                        let bundle: Int = daysOfTheWeek.count
                        let (currentRepeatFrequencyCount, remainder) = frequencyCountAndRemainder(frequency: rule.frequency, from: occurrenceDate, to: lowerBound, interval: rule.interval)
                        let occurredCount = currentRepeatFrequencyCount * bundle
                        if case .occurrenceCount(let occurrenceCount) = rule.recurrenceEnd {
                            if occurrenceCount < occurredCount {
                                continue
                            }
                        }
                        let (repeatFrequencyCount, _) = frequencyCountAndRemainder(frequency: rule.frequency, from: (occurrenceDate - remainder.months), to: upperBound, interval: rule.interval)
                        var numberOfFrequencyRemaining: Int = repeatFrequencyCount
                        var numberOfCountRemaining: Int = 0
                        if case .occurrenceCount(let occurrenceCount) = rule.recurrenceEnd {
                            let numberOfOccurrencesRemaining = occurrenceCount - occurredCount
                            (numberOfFrequencyRemaining, numberOfCountRemaining) = numberOfOccurrencesRemaining.quotientAndRemainder(dividingBy: bundle)
                        }
                        (currentRepeatFrequencyCount...numberOfFrequencyRemaining).forEach { index in
                            for dayOfWeek in daysOfTheWeek {
                                let interval: Int = rule.interval * index
                                let startOfMonth = (occurrenceDate + interval.months).dateAtStartOf(.month)
                                let date = startOfMonth + (dayOfWeek.weekNumber * 7).days + dayOfWeek.dayOfTheWeek.rawValue.days
                                if let calendarItem = makeCalendarItem(date: date, range: lowerBound..<upperBound) {
                                    calendarItems.append(calendarItem)
                                }
                            }
                        }
                        (0..<numberOfCountRemaining).forEach { index in
                            let dayOfWeek = daysOfTheWeek[index]
                            let interval: Int = numberOfFrequencyRemaining + 1
                            let startOfMonth = (occurrenceDate + interval.months).dateAtStartOf(.month)
                            let date = startOfMonth + (dayOfWeek.weekNumber * 7).days + dayOfWeek.dayOfTheWeek.rawValue.days
                            if let calendarItem = makeCalendarItem(date: date, range: lowerBound..<upperBound) {
                                calendarItems.append(calendarItem)
                            }
                        }
                    } else if let daysOfTheMonth = rule.daysOfTheMonth {
                        let bundle: Int = daysOfTheMonth.count
                        let days: [Int] = daysOfTheMonth
                        let (currentRepeatFrequencyCount, remainder) = frequencyCountAndRemainder(frequency: rule.frequency, from: occurrenceDate, to: lowerBound, interval: rule.interval)
                        let occurredCount = currentRepeatFrequencyCount * bundle
                        if case .occurrenceCount(let occurrenceCount) = rule.recurrenceEnd {
                            if occurrenceCount < occurredCount {
                                continue
                            }
                        }
                        let (repeatFrequencyCount, _) = frequencyCountAndRemainder(frequency: rule.frequency, from: (occurrenceDate - remainder.months), to: upperBound, interval: rule.interval)
                        var numberOfFrequencyRemaining: Int = repeatFrequencyCount
                        var numberOfCountRemaining: Int = 0
                        if case .occurrenceCount(let occurrenceCount) = rule.recurrenceEnd {
                            let numberOfOccurrencesRemaining = occurrenceCount - occurredCount
                            (numberOfFrequencyRemaining, numberOfCountRemaining) = numberOfOccurrencesRemaining.quotientAndRemainder(dividingBy: bundle)
                        }
                        (currentRepeatFrequencyCount...numberOfFrequencyRemaining).forEach { index in
                            for day in days {
                                let interval: Int = rule.interval * index
                                let date = occurrenceDate + interval.months + day.days
                                if let calendarItem = makeCalendarItem(date: date, range: lowerBound..<upperBound) {
                                    calendarItems.append(calendarItem)
                                }
                            }
                        }
                        (0..<numberOfCountRemaining).forEach { index in
                            let day = days[index]
                            let interval: Int = numberOfFrequencyRemaining + 1
                            let date = occurrenceDate + interval.months + day.days
                            if let calendarItem = makeCalendarItem(date: date, range: lowerBound..<upperBound) {
                                calendarItems.append(calendarItem)
                            }
                        }
                    }
                case .yearly:
                    if let monthsOfTheYear: [RecurrenceRule.Month] = rule.monthsOfTheYear {
                        let bundle: Int = monthsOfTheYear.count
                        let daysOfTheWeek: [RecurrenceRule.DayOfWeek] = rule.daysOfTheWeek ?? []
                        let (currentRepeatFrequencyCount, remainder) = frequencyCountAndRemainder(frequency: rule.frequency, from: occurrenceDate, to: lowerBound, interval: rule.interval)
                        let occurredCount = currentRepeatFrequencyCount * bundle
                        if case .occurrenceCount(let occurrenceCount) = rule.recurrenceEnd {
                            if occurrenceCount < occurredCount {
                                continue
                            }
                        }
                        let (repeatFrequencyCount, _) = frequencyCountAndRemainder(frequency: rule.frequency, from: (occurrenceDate - remainder.years), to: upperBound, interval: rule.interval)
                        var numberOfFrequencyRemaining: Int = repeatFrequencyCount
                        var numberOfCountRemaining: Int = 0
                        if case .occurrenceCount(let occurrenceCount) = rule.recurrenceEnd {
                            let numberOfOccurrencesRemaining = occurrenceCount - occurredCount
                            (numberOfFrequencyRemaining, numberOfCountRemaining) = numberOfOccurrencesRemaining.quotientAndRemainder(dividingBy: bundle)
                        }
                        (currentRepeatFrequencyCount...numberOfFrequencyRemaining).forEach { index in
                            for month in monthsOfTheYear {
                                let interval: Int = rule.interval * index
                                let startOfYear = occurrenceDate.dateAtStartOf(.year) + interval.years
                                var date = startOfYear + month.rawValue.months
                                if daysOfTheWeek.isEmpty {
                                    if let calendarItem = makeCalendarItem(date: date, range: lowerBound..<upperBound) {
                                        calendarItems.append(calendarItem)
                                    }
                                } else {
                                    for dayOfWeek in daysOfTheWeek {
                                        date = date + (dayOfWeek.weekNumber * 7).days + dayOfWeek.dayOfTheWeek.rawValue.days
                                        for dayOfWeek in daysOfTheWeek {
                                            date = date + (dayOfWeek.weekNumber * 7).days + dayOfWeek.dayOfTheWeek.rawValue.days
                                        }
                                    }
                                }
                            }
                        }
                        (0..<numberOfCountRemaining).forEach { index in
                            let month = monthsOfTheYear[index]
                            let interval: Int = numberOfFrequencyRemaining + 1
                            let startOfYear = occurrenceDate.dateAtStartOf(.year) + interval.years
                            var date = startOfYear + month.rawValue.months
                            if daysOfTheWeek.isEmpty {
                                if let calendarItem = makeCalendarItem(date: date, range: lowerBound..<upperBound) {
                                    calendarItems.append(calendarItem)
                                }
                            } else {
                                for dayOfWeek in daysOfTheWeek {
                                    date = date + (dayOfWeek.weekNumber * 7).days + dayOfWeek.dayOfTheWeek.rawValue.days
                                    for dayOfWeek in daysOfTheWeek {
                                        date = date + (dayOfWeek.weekNumber * 7).days + dayOfWeek.dayOfTheWeek.rawValue.days
                                    }
                                }
                            }
                        }
                    } else if let daysOfTheYear: [Int] = rule.daysOfTheYear {
                        let bundle: Int = daysOfTheYear.count
                        let days: [Int] = daysOfTheYear
                        let (currentRepeatFrequencyCount, remainder) = frequencyCountAndRemainder(frequency: rule.frequency, from: occurrenceDate, to: lowerBound, interval: rule.interval)
                        let occurredCount = currentRepeatFrequencyCount * bundle
                        if case .occurrenceCount(let occurrenceCount) = rule.recurrenceEnd {
                            if occurrenceCount < occurredCount {
                                continue
                            }
                        }
                        let (repeatFrequencyCount, _) = frequencyCountAndRemainder(frequency: rule.frequency, from: (occurrenceDate - remainder.years), to: upperBound, interval: rule.interval)
                        var numberOfFrequencyRemaining: Int = repeatFrequencyCount
                        var numberOfCountRemaining: Int = 0
                        if case .occurrenceCount(let occurrenceCount) = rule.recurrenceEnd {
                            let numberOfOccurrencesRemaining = occurrenceCount - occurredCount
                            (numberOfFrequencyRemaining, numberOfCountRemaining) = numberOfOccurrencesRemaining.quotientAndRemainder(dividingBy: bundle)
                        }
                        (currentRepeatFrequencyCount...numberOfFrequencyRemaining).forEach { index in
                            for day in days {
                                let interval: Int = rule.interval * index
                                let date = occurrenceDate.dateAtStartOf(.year) + interval.years + day.days
                                if let calendarItem = makeCalendarItem(date: date, range: lowerBound..<upperBound) {
                                    calendarItems.append(calendarItem)
                                }
                            }
                        }
                        (0..<numberOfCountRemaining).forEach { index in
                            let day = days[index]
                            let interval: Int = numberOfFrequencyRemaining + 1
                            let date = occurrenceDate.dateAtStartOf(.year) + interval.years + day.days
                            if let calendarItem = makeCalendarItem(date: date, range: lowerBound..<upperBound) {
                                calendarItems.append(calendarItem)
                            }
                        }
                    }
            }
        }

        return calendarItems
    }
}
