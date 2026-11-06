//
//  tequilaTests.swift
//  tequilaTests
//
//  Created by YuYou Cai on 2026/6/8.
//

import Testing
@testable import tequila

struct tequilaTests {

    @Test func ordersReversedTimedTasksByStartTime() {
        let late = TaskRecord(title: "Late", startTime: Date(timeIntervalSince1970: 54_000))
        let early = TaskRecord(title: "Early", startTime: Date(timeIntervalSince1970: 32_400))

        #expect(orderedTasksForDisplay([late, early]).map(\.id) == [early.id, late.id])
    }

    @Test func placesUntimedTasksAfterTimedTasks() {
        let untimed = TaskRecord(title: "Untimed")
        let timed = TaskRecord(title: "Timed", startTime: Date(timeIntervalSince1970: 32_400))

        #expect(orderedTasksForDisplay([untimed, timed]).map(\.id) == [timed.id, untimed.id])
    }

    @Test func preservesSavedOrderForEqualStartTimes() {
        let start = Date(timeIntervalSince1970: 32_400)
        let first = TaskRecord(title: "First", startTime: start)
        let second = TaskRecord(title: "Second", startTime: start)

        #expect(orderedTasksForDisplay([first, second]).map(\.id) == [first.id, second.id])
    }

    @Test func recurringTasksUseTheSameTimeOrdering() {
        let recurringLate = TaskRecord(title: "Recurring late", startTime: Date(timeIntervalSince1970: 54_000), isRecurring: true)
        let ordinaryEarly = TaskRecord(title: "Ordinary early", startTime: Date(timeIntervalSince1970: 32_400))

        #expect(orderedTasksForDisplay([recurringLate, ordinaryEarly]).map(\.id) == [ordinaryEarly.id, recurringLate.id])
    }

    @Test func emptyTaskListStaysEmpty() {
        #expect(orderedTasksForDisplay([]).isEmpty)
    }

    @Test func preservesUntimedTasksRelativeOrder() {
        let first = TaskRecord(title: "First")
        let second = TaskRecord(title: "Second")
        let third = TaskRecord(title: "Third")

        #expect(orderedTasksForDisplay([first, second, third]).map(\.id) == [first.id, second.id, third.id])
    }

}
