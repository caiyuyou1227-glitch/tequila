//
//  tequilaTests.swift
//  tequilaTests
//
//  Created by YuYou Cai on 2026/6/8.
//

import Testing
@testable import tequila

struct tequilaTests {

    @Test func sameTitleAndDateRemindersWithDifferentTimesAreDistinct() {
        let date = Date(timeIntervalSince1970: 1_800_000_000)
        let first = CalendarEvent(title: "Reminder", date: date, color: .red, isReminder: true, hasSpecificTime: true, startTime: date)
        let second = CalendarEvent(title: "Reminder", date: date, color: .red, isReminder: true, hasSpecificTime: true, startTime: date.addingTimeInterval(3600))

        let result = deduplicatedCalendarEvents([first, second])
        #expect(result.count == 2)
        #expect(result.map(\.id) == [first.id, second.id])
    }

    @Test func duplicateReminderIDKeepsFirstOccurrence() {
        let date = Date(timeIntervalSince1970: 1_800_000_000)
        let first = CalendarEvent(title: "First", date: date, isReminder: true)
        var duplicate = first
        duplicate.title = "Changed representation"
        let third = CalendarEvent(title: "Third", date: date, isReminder: true)

        let result = deduplicatedCalendarEvents([first, duplicate, third])
        #expect(result.count == 2)
        #expect(result[0].id == first.id)
        #expect(result[0].title == "First")
        #expect(result[1].id == third.id)
    }

    @Test func reminderOverflowCountsEveryDistinctRecord() {
        let date = Date(timeIntervalSince1970: 1_800_000_000)
        let events = (0..<4).map { CalendarEvent(title: "Reminder \($0)", date: date, isReminder: true) }

        let result = reminderDisplay(from: events, maxVisible: 2)
        #expect(result.visible.count == 2)
        #expect(result.visible.map(\.id) == Array(events.prefix(2).map(\.id)))
        #expect(result.overflow == 2)
    }

    @Test func emptyReminderDisplayHasNoVisibleEventsOrOverflow() {
        let result = reminderDisplay(from: [], maxVisible: 3)
        #expect(result.visible.isEmpty)
        #expect(result.overflow == 0)
    }

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}
