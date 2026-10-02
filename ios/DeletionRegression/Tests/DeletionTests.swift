import XCTest
import UserNotifications

@MainActor
private final class Reminders: MicrofitReminderCenter {
    var pauseAuthorization = false
    var pauseAdd = false
    var authorization: CheckedContinuation<Bool, Never>?
    var addition: CheckedContinuation<Void, Never>?
    var pending = Set<String>()
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        if pauseAuthorization { return await withCheckedContinuation { authorization = $0 } }
        return true
    }
    func add(_ request: UNNotificationRequest) async throws {
        if pauseAdd {
            pauseAdd = false
            await withCheckedContinuation { addition = $0 }
        }
        pending.insert(request.identifier)
    }
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        pending.subtract(identifiers)
    }
}

@MainActor
final class DeletionTests: XCTestCase {
    private func defaults() -> UserDefaults {
        UserDefaults(suiteName: "MicrofitRegression.\(UUID().uuidString)")!
    }
    private func waitFor(_ condition: () -> Bool) async {
        for _ in 0..<10000 {
            if condition() { return }
            await Task.yield()
        }
        XCTFail("Operation did not reach its suspension point")
    }
    func testDeletedCoachResponseCannotRestoreSnapshot() async {
        let store = defaults()
        var response: CheckedContinuation<String, Never>?
        let state = MicrofitAppState(defaults: store, reminderCenter: Reminders(), coachReplyProvider: { _ in
            await withCheckedContinuation { response = $0 }
        })
        let work = Task { await state.sendCoachMessage("I have ten minutes to move") }
        await waitFor { response != nil }
        await state.deleteAllData()
        response?.resume(returning: "Old personal coaching response")
        await work.value
        XCTAssertFalse(state.coachMessages.contains { $0.text.contains("Old personal") })
        XCTAssertNil(store.data(forKey: "microfit.snapshot.v2"))
        XCTAssertFalse(state.isWorking)
    }
    func testDeletionDuringAuthorizationSchedulesNothing() async {
        let store = defaults(); let center = Reminders(); center.pauseAuthorization = true
        let state = MicrofitAppState(defaults: store, reminderCenter: center)
        let work = Task { await state.configureReminders(enabled: true) }
        await waitFor { center.authorization != nil }
        await state.deleteAllData()
        center.authorization?.resume(returning: true)
        await work.value
        XCTAssertTrue(center.pending.isEmpty)
        XCTAssertFalse(state.remindersEnabled)
        XCTAssertNil(store.data(forKey: "microfit.snapshot.v2"))
    }
    func testDeletionDuringAddRemovesLateNotification() async {
        let store = defaults(); let center = Reminders(); center.pauseAdd = true
        let state = MicrofitAppState(defaults: store, reminderCenter: center)
        let work = Task { await state.configureReminders(enabled: true) }
        await waitFor { center.addition != nil }
        await state.deleteAllData()
        center.addition?.resume()
        await work.value
        XCTAssertTrue(center.pending.isEmpty)
        XCTAssertNil(store.stringArray(forKey: "microfit.reminderIdentifiers"))
        XCTAssertNil(store.data(forKey: "microfit.snapshot.v2"))
    }
    func testLateOldAddCannotRemoveNewReminders() async {
        let center = Reminders(); center.pauseAdd = true
        let state = MicrofitAppState(defaults: defaults(), reminderCenter: center)
        let old = Task { await state.configureReminders(enabled: true) }
        await waitFor { center.addition != nil }
        await state.deleteAllData()
        await state.configureReminders(enabled: true, hours: [11, 16])
        let newIdentifiers = center.pending
        XCTAssertEqual(newIdentifiers.count, 2)
        center.addition?.resume()
        await old.value
        XCTAssertEqual(center.pending, newIdentifiers)
        XCTAssertTrue(state.remindersEnabled)
    }
    func testDeletionAfterRestartRemovesPersistedIdentifiers() async {
        let store = defaults(); let center = Reminders()
        let first = MicrofitAppState(defaults: store, reminderCenter: center)
        await first.configureReminders(enabled: true)
        XCTAssertFalse(center.pending.isEmpty)
        let restarted = MicrofitAppState(defaults: store, reminderCenter: center)
        await restarted.deleteAllData()
        XCTAssertTrue(center.pending.isEmpty)
        XCTAssertNil(store.stringArray(forKey: "microfit.reminderIdentifiers"))
        XCTAssertNil(store.data(forKey: "microfit.snapshot.v2"))
    }
}
