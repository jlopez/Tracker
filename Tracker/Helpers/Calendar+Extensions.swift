//
//  Calendar+Extensions.swift
//  Tracker
//
//  Created by Jesus Lopez on 3/22/24.
//

import Foundation

extension Calendar {
    /// Returns the start of the day for the given date, adjusted for the waking day.
    /// The waking day starts at 4:00 AM.
    /// E.g.
    /// - Monday at 12pm will return Monday 4am
    /// - Monday at 8am will return Monday 4am
    /// - Monday at 12am will return Sunday 4am
    /// - Monday at 3am will return Sunday 4am
    ///
    /// - parameter date: The date to adjust.
    /// - returns: The start of the waking day for the given date.
    func startOfWakingDay(for date: Date) -> Date {
        startOfDay(for: date.addingTimeInterval(-4 * 60 * 60)).addingTimeInterval(4 * 60 * 60)
    }

    /// Returns the number of days between two dates.
    ///
    /// E.g.
    /// - Between Monday at 11pm and Tuesday at 1am, the result is `0`, i.e. they are considered the same day.
    /// - Between Monday at 11pm and Tuesday at 8am, the result is `1`.
    ///
    /// - parameter from: The starting date.
    /// - parameter to: The ending date.
    /// - returns: The number of waking days between the two dates.
    ///
    func numberOfWakingDaysBetween(_ from: Date, and to: Date) -> Int {
        dateComponents([.day], from: startOfWakingDay(for: from), to: startOfWakingDay(for: to)).day!
    }

    /// Returns a date that is `days` waking days ago from the given date.
    ///
    /// - parameter wakingDaysAgo: The number of waking days ago.
    /// - parameter date: The reference date.
    /// - returns: The date that is `days` waking days ago.
    func date(wakingDaysAgo days: Int, from date: Date) -> Date {
        self.date(byAdding: .day, value: -days, to: startOfWakingDay(for: date))!
    }

    /// Returns whether two dates are in the same waking day.
    /// - parameter date1: The first date.
    /// - parameter date2: The second date.
    /// - returns: `true` if both dates are in the same waking day, `false` otherwise.
    public func isDate(_ date1: Date, inSameWakingDayAs date2: Date) -> Bool {
        startOfWakingDay(for: date1) == startOfWakingDay(for: date2)
    }
}
