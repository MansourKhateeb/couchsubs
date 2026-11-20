// SPDX-License-Identifier: AGPL-3.0-only

import Foundation

/// Filters English accessibility cues from OCR while retaining the geometry of the remaining rows.
enum SoundEffects {
    // Read quoted spans as single tokens so brackets spoken or quoted verbatim are ignored.
    private static let tokens = try! NSRegularExpression(pattern:
        #""[^"]*"|“[^”]*”|«[^»]*»|(?<![\p{L}\p{N}])'(?:[^']|(?<=\p{L})'(?=\p{L}))*'(?![\p{L}\p{N}])|‘(?:[^’]|(?<=\p{L})’(?=\p{L}))*’|[()\[\]]"#)
    private static let voice = "sobbing|sobs|crying|cries|whimpering|whimpers|sniffling|sniffles|sighing|sighs|gasping|gasps|laughing|laughs|grunting|grunts|panting"
    private static let description = try! NSRegularExpression(pattern:
        "^(?:\(voice)|laughter|applause|gunfire|glass shattering"
        + "|(?:door|gate) (?:slams?|slamming|creaks?|creaking|rattles?|rattling)"
        + "|footsteps (?:thudding|approaching|receding|echoing)"
        + "|(?:thunder|engine) rumbling|wind (?:howls|howling)|phone (?:rings|ringing)"
        + "|(?:(?:gentle|soft|quiet|loud|tense|eerie|dramatic|ominous|sad|upbeat|background|instrumental|piano|ambient) ){1,2}music"
        + "|music (?:playing|starts|stops|fades (?:in|out)))$", options: .caseInsensitive)
    private static let namedDescription = try! NSRegularExpression(pattern:
        #"^((?:\p{Lu}[\p{L}'’\-]* ){1,3})(?i:\#(voice))$"#)
    private static let speechWords: Set<String> = [
        "a", "an", "the", "i", "you", "he", "she", "it", "we", "they", "no", "not", "still",
        "stop", "start", "keep", "try", "don't", "don’t", "avoid", "quit", "enough", "please", "imagine",
    ]
    private static let beforePunctuation = CharacterSet(charactersIn: ",.!?;:…)]}،؛؟”’")
    private static let afterPunctuation = CharacterSet(charactersIn: "([{“‘")

    static func removing(from reading: Reading) -> Reading {
        let text = reading.text
        guard text.contains("(") || text.contains("[") else { return reading }
        let ranges = effectRanges(in: text)
        guard !ranges.isEmpty else { return reading }
        var offset = 0
        let remaining = Reading(lines: reading.lines.compactMap { line in
            let length = line.text.utf16.count
            let lineRange = NSRange(location: offset, length: length)
            defer { offset += length + 1 }
            let cuts = ranges.map { NSIntersectionRange($0, lineRange) }.filter { $0.length > 0 }
            guard !cuts.isEmpty else { return line }
            let result = NSMutableString(string: line.text)
            for cut in cuts.reversed() {
                remove(NSRange(location: cut.location - offset, length: cut.length), from: result)
            }
            let cleaned = result.trimmingCharacters(in: .whitespaces)
            // Punctuation left by a cue on its own is part of the cue.
            guard !cleaned.unicodeScalars.allSatisfy({ CharacterSet.punctuationCharacters.contains($0)
                || CharacterSet.whitespacesAndNewlines.contains($0) }) else { return nil }
            return TextLine(cleaned, box: line.box, confidence: line.confidence)
        })
        // A speaker label without dialogue is also hidden. Keep it if dialogue follows on a second row.
        if remaining.lines.count == 1, let line = remaining.lines.first?.text,
           line.hasSuffix(":") || line.hasSuffix("："), SpeakerPrefix.split(line + " text") != nil {
            return .empty
        }
        return remaining
    }

    private static func effectRanges(in text: String) -> [NSRange] {
        let source = text as NSString
        var brackets: [String] = []
        var opening = 0
        var effects: [NSRange] = []
        for match in tokens.matches(in: text, range: NSRange(location: 0, length: source.length)) where match.range.length == 1 {
            let at = match.range.location
            let bracket = source.substring(with: match.range)
            switch bracket {
            case "(", "[":
                if brackets.isEmpty { opening = at }
                brackets.append(bracket)
            case ")", "]":
                let expected = bracket == ")" ? "(" : "["
                guard brackets.last == expected else { continue }
                brackets.removeLast()
                guard brackets.isEmpty, at - opening <= 96 else { continue }
                let contents = source.substring(with: NSRange(location: opening + 1, length: at - opening - 1))
                if isDescription(contents) { effects.append(NSRange(location: opening, length: at - opening + 1)) }
            default:
                break
            }
        }
        return effects
    }

    private static func isDescription(_ contents: String) -> Bool {
        var phrase = contents.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        if phrase.hasSuffix(".") { phrase.removeLast() }
        let range = NSRange(phrase.startIndex..., in: phrase)
        if description.firstMatch(in: phrase, range: range) != nil { return true }
        guard let named = namedDescription.firstMatch(in: phrase, range: range),
              let name = Range(named.range(at: 1), in: phrase) else { return false }
        return !phrase[name].lowercased().split(separator: " ").contains { speechWords.contains(String($0)) }
    }

    private static func remove(_ range: NSRange, from text: NSMutableString) {
        var start = range.location
        var end = NSMaxRange(range)
        while start > 0, contains(.whitespaces, text.character(at: start - 1)) { start -= 1 }
        while end < text.length, contains(.whitespaces, text.character(at: end)) { end += 1 }
        let needsSpace = start > 0 && end < text.length
            && !contains(afterPunctuation, text.character(at: start - 1))
            && !contains(beforePunctuation, text.character(at: end))
        text.replaceCharacters(in: NSRange(location: start, length: end - start), with: needsSpace ? " " : "")
    }

    private static func contains(_ characters: CharacterSet, _ unit: unichar) -> Bool {
        UnicodeScalar(unit).map(characters.contains) ?? false
    }
}
