//
//  DateFormatter.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 10/04/22.
//

import Foundation
private enum Constants {
    static let formatter = DateFormatter()
    static let dateFormat = "dd/MM/yyyy"
    static let calendar = Calendar.current
}

extension Date {
    func asString() -> String {
        Constants.formatter.dateFormat = Constants.dateFormat
        Constants.formatter.timeZone = .current
        return Constants.formatter.string(from: self)
    }
    
    func difference(from date: Date) -> String {
        let fromDate = Constants.calendar.startOfDay(for: self)
        let toDate = Constants.calendar.startOfDay(for: date)
        let numberOfDays = Constants.calendar.dateComponents([.day], from: fromDate, to: toDate).day
        guard var numberOfDays = numberOfDays else {
            return "Zero.Days".localized
        }
        let years = numberOfDays/365
        numberOfDays = numberOfDays - years * 365
        let months = numberOfDays/30
        numberOfDays = numberOfDays - months * 30
        let weeks = numberOfDays/7
        numberOfDays = numberOfDays - weeks * 7
        
        if years > 0 {
            return "\(years) \(years > 1 ? "Years".localized : "Year".localized)"
        } else if months > 0 {
            return "\(months) \(months > 1 ? "Months".localized : "Month".localized)"
        } else if weeks > 0 {
            return "\(weeks) \(weeks > 1 ? "Weeks".localized : "Week".localized)"
        } else if numberOfDays > 0 {
            return"\(numberOfDays) \(numberOfDays > 1 ? "Days".localized : "Day".localized)"
        } else {
            return "Zero.Days".localized
        }
    }
    
    func isPastDueDate() -> Bool {
        self.difference(from: Date()) == "Zero.Days".localized
    }
}

extension String {
    func asDate() -> Date? {
        Constants.formatter.dateFormat = Constants.dateFormat
        Constants.formatter.timeZone = .current
        return Constants.formatter.date(from: self)
    }
}
