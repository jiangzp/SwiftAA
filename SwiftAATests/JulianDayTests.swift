//
//  JulianDayTest.swift
//  SwiftAA
//
//  Created by Cédric Foellmi on 17/09/2016.
//  Copyright © 2016 onekiloparsec. All rights reserved.
//

import XCTest
@testable import SwiftAA

class JulianDayTest: XCTestCase {
    
    func testDate1ToJulianDay() {
        var components = DateComponents()
        components.year = 2016
        components.month = 9
        components.day = 17
        let date = Calendar.gregorianGMT.date(from: components)
        XCTAssertEqual(date?.julianDay, 2457648.500000)
    }

    func testDate2ToJulianDay() {
        var components = DateComponents()
        components.year = 1916
        components.month = 9
        components.day = 17
        components.hour = 2
        components.minute = 3
        components.second = 4
        components.nanosecond = 500000000
        let date = Calendar.gregorianGMT.date(from: components)!
        let jd = JulianDay(2421123.5 + 2.0/24.0 + 3.0/1440.0 + (4.0+500000000/1e9)/86400.0)
        AssertEqual(date.julianDay, jd, accuracy: Second(0.001).inDays)
    }

    func testJulianDayToDateComponents() {
        let julianDay = JulianDay(2421123.585469)
        let components = Calendar.gregorianGMT.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: julianDay.date)
        XCTAssertEqual(components.year!, 1916)
        XCTAssertEqual(components.month!, 9)
        XCTAssertEqual(components.day!, 17)
        XCTAssertEqual(components.hour!, 2)
        XCTAssertEqual(components.minute!, 3)
        XCTAssertEqual(components.second!, 4)
        XCTAssertEqualWithAccuracy(Double(components.nanosecond!)/1e9, 521659000/1e9, accuracy: 0.001)
    }
    
    func testJulian2016() {
        let components = DateComponents(year: 2016, month: 12, day: 21, hour: 01, minute: 04, second: 09, nanosecond: Int(0.1035*1e9))
        let jd = JulianDay(2457743.5 + 01.0/24.0 + 04.0/1440.0 + 09.1035/86400)
        testJulian(components, jd)
        let jd2 = JulianDay(year: 2016, month: 12, day: 21, hour: 1, minute: 4, second: 9.1035)
        AssertEqual(jd, jd2, accuracy: Second(0.001).inDays)
    }
    
    func testJulian1980() {
        let components = DateComponents(year: 1980, month: 03, day: 15, hour: 03, minute: 47, second: 05, nanosecond: 0)
        let jd = JulianDay(2444313.5 + 03.0/24.0 + 47.0/1440.0 + 05.0/86400.0)
        testJulian(components, jd)
    }
    
    func testJulian1932() {
        let components = DateComponents(year: 1932, month: 10, day: 02, hour: 21, minute: 15, second: 59, nanosecond: 0)
        let jd = JulianDay(2426982.5 + 21.0/24.0 + 15.0/1440.0 + 59.0/86400.0)
        testJulian(components, jd)
    }
    
    func testJulian(_ components: DateComponents, _ jd: JulianDay) {
        let date = Calendar.gregorianGMT.date(from: components)!
        let date1 = jd.date
        let jd1 = date.julianDay
        let date2 = jd1.date
        let jd2 = date1.julianDay
        let accuracy = TimeInterval(0.001)
        XCTAssertEqualWithAccuracy(date.timeIntervalSinceReferenceDate, date1.timeIntervalSinceReferenceDate, accuracy: accuracy)
        XCTAssertEqualWithAccuracy(date.timeIntervalSinceReferenceDate, date2.timeIntervalSinceReferenceDate, accuracy: accuracy)
        AssertEqual(jd, jd1, accuracy: Second(accuracy).inDays)
        AssertEqual(jd, jd2, accuracy: Second(accuracy).inDays)
    }
    
    func testMeanSiderealTime1() { // See AA p.88
        let jd = JulianDay(year: 1987, month: 04, day: 10)
        let gmst = jd.meanGreenwichSiderealTime()
        AssertEqual(gmst, Hour(13, 10, 46.3668), accuracy: Second(0.001).inHours)
    }
    
    func testMeanSiderealTime2() { // See AA p.89
        let jd = JulianDay(year: 1987, month: 04, day: 10, hour: 19, minute: 21, second: 00)
        let gmst = jd.meanGreenwichSiderealTime()
        AssertEqual(gmst, Hour(8, 34, 57.0898), accuracy: Second(0.001).inHours)
    }
    
    func testMeanLocalSiderealTime1() { // Data from SkySafari
        let jd = JulianDay(year: 2016, month: 12, day: 1, hour: 14, minute: 15, second: 3)
        let geographic = GeographicCoordinates(positivelyWestwardLongitude: -37.615559, latitude: 55.752220)
        let lmst = jd.meanLocalSiderealTime(forGeographicLongitude: geographic.longitude.value)
        AssertEqual(lmst, Hour(21, 28, 59.0), accuracy: Second(1.0).inHours)
    }
    
    func testMidnight() {
        let jd1 = JulianDay(year: 2016, month: 12, day: 20, hour: 3, minute: 5, second: 3.5)
        AssertEqual(jd1.midnight, JulianDay(year: 2016, month: 12, day: 20))
        let jd2 = JulianDay(year: 2016, month: 12, day: 19, hour: 23, minute: 13, second: 39.1)
        AssertEqual(jd2.midnight, JulianDay(year: 2016, month: 12, day: 19))
    }
    
}


