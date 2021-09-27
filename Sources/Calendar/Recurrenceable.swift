//
//  Recurrenceable.swift
//  
//
//  Created by nori on 2021/09/23.
//

import Foundation
import RecurrenceRule

public protocol Recurrenceable: TimeframeRepresentable {

    var occurrenceDate: Date { get }

    var recurrenceRules: [RecurrenceRule] { get }
}
