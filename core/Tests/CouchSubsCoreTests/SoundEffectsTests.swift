// SPDX-License-Identifier: AGPL-3.0-only

import XCTest
@testable import CouchSubsCore

final class SoundEffectsTests: XCTestCase {
    func testStandaloneDescriptionsAreDropped() {
        for text in ["(Rose sobbing)", "[Door slams]", "(footsteps thudding)", "(gentle music)",
                     "[ROSE SOBBING]...", "[sighs] [door slams]", "ROSE: (sobbing)"] {
            XCTAssertEqual(SoundEffects.removing(from: Reading(text: text)), .empty, text)
        }
    }

    func testMixedDialogueKeepsNamesAndPunctuation() {
        let text = "[Door slams] LUCIA: Wait (sobbing), please! [footsteps thudding]\nJASON: I'll stay. (gentle music)"
        let filtered = SoundEffects.removing(from: Reading(text: text))
        XCTAssertEqual(filtered.text, "LUCIA: Wait, please!\nJASON: I'll stay.")
    }

    func testWrappedCueIsRemovedAndDialogueKeepsItsBox() {
        let box = TextBox(left: 0.4, top: 0.8, right: 0.6, bottom: 0.84)
        let reading = Reading(lines: [
            TextLine("(footsteps"), TextLine("thudding)"),
            TextLine("ROSE: [sobbing]"), TextLine("I'm okay.", box: box, confidence: 0.9),
        ])
        let filtered = SoundEffects.removing(from: reading)
        XCTAssertEqual(filtered.lines, [TextLine("ROSE:"), TextLine("I'm okay.", box: box, confidence: 0.9)])
    }

    func testBracketedSpeechAndMeaningfulAsidesArePreserved() {
        for text in ["[We have to go.]", "[ROSE: Run!]", "[\"Gentle music\"]", "[I hear footsteps]",
                     "[Stop sobbing]", "[DOOR SLAMS?]", "Take the road (the one by the river).",
                     "Say “(gentle music)” out loud.", "The sign says 'Rose's [Door slams]'.",
                     "I need (as I said [sobbing] earlier) an answer.", "Select [Music] in Settings."] {
            let reading = Reading(text: text)
            XCTAssertEqual(SoundEffects.removing(from: reading), reading, text)
        }
    }
}
