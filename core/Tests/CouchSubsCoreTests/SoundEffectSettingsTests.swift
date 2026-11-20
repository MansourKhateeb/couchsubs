// SPDX-License-Identifier: AGPL-3.0-only

import XCTest
@testable import CouchSubsCore

final class SoundEffectSettingsTests: XCTestCase {
    func testLegacySettingsUseTargetLanguageDefaults() throws {
        var settings = try JSONDecoder().decode(UserSettings.self, from: Data(#"{"targetLanguage":"ar","gamePacks":false}"#.utf8))
        XCTAssertTrue(settings.hideSoundEffects)
        XCTAssertFalse(settings.gamePacks)
        settings.targetLanguage = "tr"
        XCTAssertFalse(settings.hideSoundEffects)
        settings.targetLanguage = "de"
        XCTAssertFalse(settings.hideSoundEffects)
    }

    func testPerLanguageChoicesSurviveSwitchingAndReloading() throws {
        var settings = UserSettings()
        XCTAssertFalse(settings.hideSoundEffects)
        settings.targetLanguage = "ar"
        XCTAssertTrue(settings.hideSoundEffects)
        settings.hideSoundEffects = false
        settings.targetLanguage = "tr"
        XCTAssertFalse(settings.hideSoundEffects)
        settings.hideSoundEffects = true

        var restored = try JSONDecoder().decode(UserSettings.self, from: JSONEncoder().encode(settings))
        XCTAssertTrue(restored.hideSoundEffects)
        restored.targetLanguage = "ar"
        XCTAssertFalse(restored.hideSoundEffects)
    }
}
