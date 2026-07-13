package com.mochasmindlab.mlhealth.util

/**
 * A small RFC-4180-compliant CSV parser.
 *
 * Handles quoted fields, embedded commas, escaped quotes (""), and both LF and
 * CRLF line endings. Naive line-splitting breaks on food names that contain
 * commas, which is exactly what MyFitnessPal exports contain, so imports use
 * this instead. Mirrors the iOS CSVParser.
 */
object CsvParser {

    /** Parse raw CSV text into rows of string fields. */
    fun parse(text: String): List<List<String>> {
        var input = text
        // Strip UTF-8 BOM some exporters prepend.
        if (input.isNotEmpty() && input[0] == '﻿') input = input.substring(1)

        val rows = mutableListOf<List<String>>()
        val field = StringBuilder()
        var record = mutableListOf<String>()
        var inQuotes = false
        var i = 0

        fun endField() {
            record.add(field.toString())
            field.setLength(0)
        }
        fun endRecord() {
            endField()
            // Skip fully-empty records (a lone blank line).
            if (!(record.size == 1 && record[0].isEmpty())) {
                rows.add(record)
            }
            record = mutableListOf()
        }

        while (i < input.length) {
            val c = input[i]
            if (inQuotes) {
                if (c == '"') {
                    if (i + 1 < input.length && input[i + 1] == '"') {
                        field.append('"')   // escaped quote
                        i++
                    } else {
                        inQuotes = false
                    }
                } else {
                    field.append(c)
                }
            } else {
                when (c) {
                    '"' -> inQuotes = true
                    ',' -> endField()
                    '\r' -> {
                        if (i + 1 < input.length && input[i + 1] == '\n') i++
                        endRecord()
                    }
                    '\n' -> endRecord()
                    else -> field.append(c)
                }
            }
            i++
        }
        if (field.isNotEmpty() || record.isNotEmpty()) endRecord()
        return rows
    }

    /**
     * Parse into a header list plus rows keyed by the (lower-cased, trimmed)
     * header. Missing trailing fields are treated as empty.
     */
    fun parseWithHeaders(text: String): Pair<List<String>, List<Map<String, String>>> {
        val raw = parse(text)
        if (raw.isEmpty()) return Pair(emptyList(), emptyList())
        val headers = raw.first().map { it.trim() }
        val rows = raw.drop(1).map { fields ->
            val map = mutableMapOf<String, String>()
            headers.forEachIndexed { idx, header ->
                map[header.lowercase()] = if (idx < fields.size) fields[idx] else ""
            }
            map
        }
        return Pair(headers, rows)
    }
}
