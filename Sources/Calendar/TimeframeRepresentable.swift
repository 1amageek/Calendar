//
//  TimeframeRepresentable.swift
//  TimeframeRepresentable
//
//  Created by nori on 2021/09/16.
//

import Foundation

public protocol TimeframeRepresentable: Hashable {
    var startDate: Date { get }
    var endDate: Date { get }
    var timeZone: TimeZone? { get }
}
