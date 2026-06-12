package com.mochasmindlab.mlhealth.utils

import java.time.LocalDate
import java.time.ZoneId
import java.util.Date

object DateConverter {
    fun localDateToDate(localDate: LocalDate?): Date? {
        return localDate?.atStartOfDay(ZoneId.systemDefault())?.toInstant()?.let { Date.from(it) }
    }

    fun dateToLocalDate(date: Date?): LocalDate? {
        return date?.toInstant()?.atZone(ZoneId.systemDefault())?.toLocalDate()
    }
}