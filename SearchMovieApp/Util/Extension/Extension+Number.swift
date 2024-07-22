//
//  Extension+Int.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/12.
//

import UIKit

extension Int {
    var minuteToHour: String {
        get {
            let hours = self / 60
            let minutes = self % 60
            return "\(hours)h \(minutes)m"
        }
    }
    
    var numberWithComma: String {
        get {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter.string(from: NSNumber(value: self))!
        }
    }
}

extension Double {
    var getTwoDecimal: String {
        get {
            return String(format: "%.2f", self)
        }
    }
    
    var getOnlyDecimalPoint: Double {
        get {
            return self.truncatingRemainder(dividingBy: 1)
        }
    }
}
