//
//  Date+Time.swift
//  Date+Time
//
//  Created by nori on 2021/09/05.
//

import Foundation

extension Date {
    public var time: Int { Int(floor(self.timeIntervalSince1970)) }
}

extension Range where Bound == Date {
    public var time: Range<Int> { self.lowerBound.time..<self.upperBound.time }
}

extension Int {
    public var date: Date { Date(timeIntervalSince1970: TimeInterval(self)) }
}

