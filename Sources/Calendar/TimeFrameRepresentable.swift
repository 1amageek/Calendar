//
//  TimeFrameRepresentable.swift
//  TimeFrameRepresentable
//
//  Created by nori on 2021/09/16.
//

import Foundation

public protocol TimeFrameRepresentable: Hashable {
    var period: Range<Date> { get }
    var timeZone: TimeZone? { get }
}
