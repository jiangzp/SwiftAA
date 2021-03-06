//
//  JulianDay.swift
//  SwiftAA
//
//  Created by Cédric Foellmi on 26/06/16.
//  Copyright © 2016 onekiloparsec. All rights reserved.
//

import Foundation

public struct JulianDay: NumericType {
    
    public let value: Double
    
    public init(_ value: Double) {
        self.value = value
    }
    
    public init(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Double = 0.0) {
        let aaDate = KPCAADate(year: year, month: month, day: Double(day), hour: Double(hour), minute: Double(minute), second: second, usingGregorianCalendar: true)!
        self.init(aaDate.julian())
    }
    
    public init(_ date: Date) {
        let components = Calendar.gregorianGMT.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
        let decimalSeconds = Double(components.second!) + Double(components.nanosecond!)/1e9
        self.init(year: components.year!, month: components.month!, day: components.day!, hour: components.hour!, minute: components.minute!, second: decimalSeconds)
    }
    
}

public extension JulianDay {
    /**
     Transform a julian day into a Date.
     
     - returns: The corresponding Date instance.
     */
    public var date: Date {
        let aaDate = KPCAADate(julianDay: value, usingGregorianCalendar: true)!
        let decimalSeconds = aaDate.second()
        let roundedSeconds = decimalSeconds.rounded(.towardZero)
        let nanoseconds = (decimalSeconds - roundedSeconds) * 1e9
        let components = DateComponents(year: aaDate.year(), month: aaDate.month(), day: aaDate.day(), hour: aaDate.hour(), minute: aaDate.minute(), second: Int(roundedSeconds), nanosecond: Int(nanoseconds))
        let date = Calendar.gregorianGMT.date(from: components)!
        return date
    }
    
    public var modified: JulianDay {
        get { return JulianDay(self.value - ModifiedJulianDayZero) }
    }
    
    public var midnight: JulianDay { return JulianDay((value - 0.5).rounded(.down) + 0.5) }
    
    /**
     Computes the mean sidereal time for the Greenwich meridian.
     That is, the Greenwich hour angle of the mean vernal point (the intersection of the ecliptic
     of the date with the mean equator of the date).
     
     - returns: The sidereal time in hours.
     */
    public func meanGreenwichSiderealTime() -> Hour {
        return Hour(KPCAASidereal_MeanGreenwichSiderealTime(self.value))
    }

    /**
     Computes the mean sidereal time for a given longitude on Earth.
     
     - parameter longitude: Positively Westward (see AA p. 93 for explanations).
     Basically: this is the contrary of IAU decision. But this orientation is consistent
     with longitude orientation in all other planets!
     
     - returns: The sidereal time in hours.
     */
    public func meanLocalSiderealTime(forGeographicLongitude longitude: Double) -> Hour {
        return Hour(self.meanGreenwichSiderealTime().value - RadiansToHours(DegreesToRadians(longitude)))
    }

    /**
     Computes the apparent sidereal time.
     That is, the Greenwich hour angle of the true vernal equinox, obtained by adding a correction
     that depends on the nutation in longitude, and the true obliquity of the ecliptic.
     
     - returns: The sidereal time in hours.
     */
    public func apparentGreenwichSiderealTime() -> Hour {
        return Hour(KPCAASidereal_ApparentGreenwichSiderealTime(self.value))
    }
    
    // MARK: - Dynamical Times
    
    public func deltaT() -> JulianDay {
        return JulianDay(KPCAADynamicalTime_DeltaT(self.value))
    }
    
    public func cumulativeLeapSeconds() -> JulianDay {
        return JulianDay(KPCAADynamicalTime_CumulativeLeapSeconds(self.value))
    }

    public func TTtoUTC() -> JulianDay {
        return JulianDay(KPCAADynamicalTime_TT2UTC(self.value))
    }

    public func UTCtoTT() -> JulianDay {
        return JulianDay(KPCAADynamicalTime_UTC2TT(self.value))
    }

    public func TTtoTAI() -> JulianDay {
        return JulianDay(KPCAADynamicalTime_TT2TAI(self.value))
    }

    public func TAItoTT() -> JulianDay {
        return JulianDay(KPCAADynamicalTime_TAI2TT(self.value))
    }

    public func TTtoUT1() -> JulianDay {
        return JulianDay(KPCAADynamicalTime_TT2UT1(self.value))
    }

    public func UT1toTT() -> JulianDay {
        return JulianDay(KPCAADynamicalTime_UT12TT(self.value))
    }

    public func UT1minusUTC() -> JulianDay {
        return JulianDay(KPCAADynamicalTime_UT1MinusUTC(self.value))
    }
}

public extension Date {
    /**
     Computes the Julian Day from the date.
     
     - returns: The value of the Julian Day, as a fractional (double) number.
     */
    public var julianDay: JulianDay {
        return JulianDay(self)
    }
    
    public var year: Int {
        get { return Calendar.gregorianGMT.component(.year, from: self) }
    }
    
    public var month: Int {
        get { return Calendar.gregorianGMT.component(.month, from: self) }
    }

    public var day: Int {
        get { return Calendar.gregorianGMT.component(.day, from: self) }
    }

    public var hour: Int {
        get { return Calendar.gregorianGMT.component(.hour, from: self) }
    }

    public var minute: Int {
        get { return Calendar.gregorianGMT.component(.minute, from: self) }
    }

    public var second: Int {
        get { return Calendar.gregorianGMT.component(.second, from: self) }
    }

    public var nanosecond: Int {
        get { return Calendar.gregorianGMT.component(.nanosecond, from: self) }
    }
    
    public var isLeap : Bool {
        get { return ((self.year % 100) == 0) ? (self.year % 400) == 0 : (self.year % 4) == 0 }
    }
    
    public func januaryFirstDate() -> Date {
        var components = DateComponents()
        components.year = self.year
        components.month = 1
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        return Calendar.gregorianGMT.date(from: components)!
    }
    
    public var fractionalYear: Double {
        get {
            let daysCount = (self.isLeap) ? 366.0 : 365.0
            return Double(self.year) + ((self.julianDay.value - self.januaryFirstDate().julianDay.value) / daysCount)
        }
    }
}


extension Calendar {
    static let gregorianGMT: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()
}
  
extension JulianDay: CustomStringConvertible {
    public var description: String {
        switch self {
        case StandardEpoch_J2000_0: return "J2000.0"
        case StandardEpoch_B1950_0: return "B1950.0"
        default: return String(format: "JD %.2f", value)
        }
    }
}


