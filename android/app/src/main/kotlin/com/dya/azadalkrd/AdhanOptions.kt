package com.dya.azadalkrd

/**
 * Adhan (call to prayer) options for the app.
 * Labels and raw resource names; actual files go in res/raw/<rawName>.mp3
 */
object AdhanOptions {
    data class Option(val label: String, val rawName: String)

    private val options = listOf(
        Option("بانگی ڕاست خام — نێوەرەوی عصر", "adhan1"),
        Option("أذان الحجاز ٢", "adhan2"),
        Option("أذان العراقي جديد", "adhan3"),
        Option("أذان کورد ٢", "adhan4"),
        Option("بانگی بیلالی حەبەشی — بەیانیان", "adhan_5"),
        Option("بانگی حەزینی کورد — عیشایان", "adhan_6"),
        Option("بانگی ڕاست ٢ — نێوەرەوی عصر", "adhan_7"),
        Option("بانگی کورد — بەیانی", "adhan_8"),
        Option("بانگی مەککی — حجاز (مغربان و عشایان)", "adhan_9"),
        Option("بانگی صبا — مغربان و عیشایان", "adhan_10"),
        Option("م.رمزان شکور — بەیانی و مغربان", "adhan_11"),
        Option("بانگی مەدینە — مغرب و عیشایان", "adhan_12"),
        Option("بانگی لامی عێراقی ئازاد", "adhan_13"),
        Option("هۆمایۆن", "adhan_14"),
    )

    fun list(): List<Option> = options

    /** For method channel: list of maps with "label" and "rawName" */
    fun toMapList(): List<Map<String, String>> =
        options.map { mapOf("label" to it.label, "rawName" to it.rawName) }
}
