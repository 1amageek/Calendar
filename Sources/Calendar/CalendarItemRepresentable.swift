//
//  CalendarItemRepresentable.swift
//  CalendarItemRepresentable
//
//  Created by nori on 2021/09/16.
//

import Foundation


public protocol CalendarItemRepresentable: Identifiable, Hashable, TimeFrameRepresentable {

    var title: String { get set }

    var isAllDay: Bool { get set }
}
