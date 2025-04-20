//
//  DateFormatter.swift
//  Packing
//
//  Created by 이융의 on 4/20/25.
//

import Foundation

extension DateFormatter {
    static let journeyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}

