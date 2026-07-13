import Foundation

/// A small RFC-4180-compliant CSV parser.
///
/// Handles quoted fields, embedded commas, escaped quotes (""), and both
/// LF and CRLF line endings. The naive line-splitting used elsewhere
/// (e.g. USDACSVImporter) breaks on food names that contain commas, which is
/// exactly what MyFitnessPal exports contain, so imports use this instead.
enum CSVParser {

    /// Parse raw CSV text into rows of string fields.
    /// Empty trailing lines are ignored. Does not trim field whitespace
    /// (callers decide), except it strips a leading UTF-8 BOM if present.
    static func parse(_ text: String) -> [[String]] {
        var input = Substring(text)
        // Strip UTF-8 BOM some exporters prepend.
        if input.first == "\u{FEFF}" { input = input.dropFirst() }

        var rows: [[String]] = []
        var field = ""
        var record: [String] = []
        var inQuotes = false
        var i = input.startIndex

        func endField() {
            record.append(field)
            field = ""
        }
        func endRecord() {
            endField()
            // Skip fully-empty records (a lone blank line).
            if !(record.count == 1 && record[0].isEmpty) {
                rows.append(record)
            }
            record = []
        }

        while i < input.endIndex {
            let c = input[i]
            if inQuotes {
                if c == "\"" {
                    let next = input.index(after: i)
                    if next < input.endIndex && input[next] == "\"" {
                        field.append("\"")   // escaped quote
                        i = next
                    } else {
                        inQuotes = false
                    }
                } else {
                    field.append(c)
                }
            } else {
                switch c {
                case "\"":
                    inQuotes = true
                case ",":
                    endField()
                case "\r":
                    // Handle CRLF: consume the following LF if present.
                    let next = input.index(after: i)
                    if next < input.endIndex && input[next] == "\n" { i = next }
                    endRecord()
                case "\n":
                    endRecord()
                default:
                    field.append(c)
                }
            }
            i = input.index(after: i)
        }
        // Flush the final field/record if the file didn't end with a newline.
        if !field.isEmpty || !record.isEmpty {
            endRecord()
        }
        return rows
    }

    /// Parse into dictionaries keyed by the (case-insensitive, trimmed) header row.
    /// Returns the header list and the rows. Missing trailing fields are treated as empty.
    static func parseWithHeaders(_ text: String) -> (headers: [String], rows: [[String: String]]) {
        let raw = parse(text)
        guard let headerRow = raw.first else { return ([], []) }
        let headers = headerRow.map { $0.trimmingCharacters(in: .whitespaces) }
        let rows: [[String: String]] = raw.dropFirst().map { fields in
            var dict: [String: String] = [:]
            for (idx, header) in headers.enumerated() {
                let key = header.lowercased()
                dict[key] = idx < fields.count ? fields[idx] : ""
            }
            return dict
        }
        return (headers, rows)
    }
}
