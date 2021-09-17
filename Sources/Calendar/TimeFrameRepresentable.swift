//
//  TimeFrameRepresentable.swift
//  TimeFrameRepresentable
//
//  Created by nori on 2021/09/16.
//

import Foundation

public protocol TimeFrameRepresentable {
    var period: Range<Date> { get }
}
