//
//  EventRepresentable.swift
//  EventRepresentable
//
//  Created by nori on 2021/09/17.
//

import Foundation
import RecurrenceRule

public protocol EventRepresentable: CalendarItemRepresentable, Recurrenceable {

    var occurrenceDate: Date { get }

}
