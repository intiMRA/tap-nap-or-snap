//
//  DateFormatter.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 10/04/22.
//

import Foundation
private enum Constants {
    static let formatter = DateFormatter()
    static let dateFormat = "dd/mm/yyyy"
    static let calendar = Calendar.current
}

extension Date {
    func asString() -> String {
        Constants.formatter.dateFormat = Constants.dateFormat
        Constants.formatter.timeZone = .current
        return Constants.formatter.string(from: self)
    }
    
    func day() -> Int {
        Constants.calendar.component(.day, from: self)
    }
}

extension String {
    func asDate() -> Date? {
        Constants.formatter.dateFormat = Constants.dateFormat
        Constants.formatter.timeZone = .current
        return Constants.formatter.date(from: self)
    }
}
