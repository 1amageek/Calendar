//
//  EventRepresentable.swift
//  EventRepresentable
//
//  Created by nori on 2021/09/17.
//

import Foundation
import RecurrenceRule

public protocol EventRepresentable: CalendarItemRepresentable {

    var occurrenceDate: Date { get set }

    var recurrenceRules: [RecurrenceRule] { get set }
}
