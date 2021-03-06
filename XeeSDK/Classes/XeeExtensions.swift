//
//  Extensions.swift
//  XeeSDK
//
//  Created by Jean-Baptiste Dujardin on 05/10/2017.
//

public extension Formatter {
    public static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}

public extension Date {
    public var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

public extension String {
    public var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}

public extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
    var resaon: String? { return (self as NSError).localizedFailureReason }
    var suggestion: String? { return (self as NSError).localizedRecoverySuggestion }
}
