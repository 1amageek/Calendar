////
////  EventStore.swift
////  EventStore
////
////  Created by nori on 2021/09/13.
////
//
//import Foundation
//
//public protocol EventStoreProtocol {
//
//    associatedtype Element
//
//    var events: [Element] { get }
//}
//
//extension EventStoreProtocol where Self.Element: EventRepeatable {
//
//    public func events(range: Range<Date>) -> [Element] {
//        if events.isEmpty { return [] }
//        return events.reduce(Array<Element>()) { prev, event in
//            let events = [event] + repeatEvents(event, range: range)
//            return prev + events
//        }
//    }
//
//    func repeatEvents(_ event: Element, range: Range<Date>) -> [Element] {
//        if events.isEmpty { return [] }
//        let calendar = Foundation.Calendar(identifier: .gregorian)
//        var events: [Element] = []
//
//        for rule in event.recurrenceRules {
//            if case .endDate(let date) = rule.recurrenceEnd {
//                if date < range.lowerBound { continue }
//            }
//
//            func shouldRepeat(date: Date, count: Int) -> Bool {
//                if let end = rule.recurrenceEnd {
//                    switch end {
//                        case .occurrenceCount(let occurrenceCount): return count < occurrenceCount
//                        case .endDate(let endDate): return date < endDate
//                    }
//                }
//                return date < range.upperBound
//            }
//
//            switch rule.frequency {
//                case .daily:
//
//                    var count: Int = 1
//                    var date: Date!
//
//                    repeat {
//                        let interval: Int = rule.interval * count
//                        date = calendar.date(byAdding: .day, value: interval, to: event.occurrenceDate)
//                        let components = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
//                        switch event.period {
//                            case .allday:
//                                let repeatItem: Element = event.duplicate(period: .allday(date))
//                                events.append(repeatItem)
//                            case .byTimes(let byTime):
//                                let startDate = calendar.setTime(components: components, date: byTime.lowerBound)
//                                let endDate = calendar.setTime(components: components, date: byTime.upperBound)
//                                let repeatItem: Element = event.duplicate(period: .byTimes((startDate..<endDate)))
//                                events.append(repeatItem)
//                        }
//                        count += 1
//                    } while (shouldRepeat(date: date, count: count))
//
//
//                case .weekly:
//
//                    var count: Int = 1
//                    var date: Date!
//
//                    repeat {
//                        let interval: Int = rule.interval * 7 * count
//                        date = calendar.date(byAdding: .day, value: interval, to: event.occurrenceDate)
//                        let components = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
//                        switch event.period {
//                            case .allday:
//                                let repeatItem: Element = event.duplicate(period: .allday(date))
//                                events.append(repeatItem)
//                            case .byTimes(let byTime):
//                                let startDate = calendar.setTime(components: components, date: byTime.lowerBound)
//                                let endDate = calendar.setTime(components: components, date: byTime.upperBound)
//                                let repeatItem: Element = event.duplicate(period: .byTimes((startDate..<endDate)))
//                                events.append(repeatItem)
//                        }
//                        count += 1
//                    } while (shouldRepeat(date: date, count: count))
//
//                case .monthly:
//
//                    var count: Int = 1
//                    var date: Date!
//
//                    repeat {
//                        let interval: Int = rule.interval * count
//                        date = calendar.date(byAdding: .month, value: interval, to: event.occurrenceDate)
//                        let components = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
//                        switch event.period {
//                            case .allday:
//                                let repeatItem: Element = event.duplicate(period: .allday(date))
//                                events.append(repeatItem)
//                            case .byTimes(let byTime):
//                                let startDate = calendar.setTime(components: components, date: byTime.lowerBound)
//                                let endDate = calendar.setTime(components: components, date: byTime.upperBound)
//                                let repeatItem: Element = event.duplicate(period: .byTimes((startDate..<endDate)))
//                                events.append(repeatItem)
//                        }
//                        count += 1
//                    } while (shouldRepeat(date: date, count: count))
//
//                case .yearly:
//
//                    var count: Int = 1
//                    var date: Date!
//
//                    repeat {
//                        let interval: Int = rule.interval * count
//                        date = calendar.date(byAdding: .year, value: interval, to: event.occurrenceDate)
//                        let components = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
//                        switch event.period {
//                            case .allday:
//                                let repeatItem: Element = event.duplicate(period: .allday(date))
//                                events.append(repeatItem)
//                            case .byTimes(let byTime):
//                                let startDate = calendar.setTime(components: components, date: byTime.lowerBound)
//                                let endDate = calendar.setTime(components: components, date: byTime.upperBound)
//                                let repeatItem: Element = event.duplicate(period: .byTimes((startDate..<endDate)))
//                                events.append(repeatItem)
//                        }
//                        count += 1
//                    } while (shouldRepeat(date: date, count: count))
//            }
//        }
//
//        return events
//    }
//
//}
//
//extension Foundation.Calendar {
//    func setTime(components: DateComponents, date: Date) -> Date {
//        var components = components
//        let hour = self.component(.hour, from: date)
//        let minute = self.component(.minute, from: date)
//        let second = self.component(.second, from: date)
//        components.hour = hour
//        components.minute = minute
//        components.second = second
//        return self.date(from: components)!
//    }
//}
